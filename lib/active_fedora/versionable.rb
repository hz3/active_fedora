module ActiveFedora
  module Versionable
    extend ActiveSupport::Concern

    included do
      class_attribute :versionable
    end

    module ClassMethods
      def has_many_versions
        self.versionable = true
      end
    end

    def model_type
      if self.respond_to?(:metadata)
        metadata.ldp_source.graph.query(predicate: ::RDF.type).objects
      else
        resource.query(subject: resource.rdf_subject, predicate: ::RDF.type).objects
      end
    end

    # Returns an array of RDF::Literal objects where the version label matches
    # our own version label and excludes auto-snapshot versions from Fedora.
    def versions
      results = versions_graph.query([nil, ::RDF::URI.new('http://fedora.info/definitions/v4/repository#hasVersionLabel'), nil])
      numbered_versions(results)
    end

    def versions_graph
      @versions_graph ||= ::RDF::Graph.new << ::RDF::Reader.for(:ttl).new(versions_request)
    end

    def versions_url
      uri + '/fcr:versions'
    end

    def create_version
      resp = ActiveFedora.fedora.connection.post(versions_url, nil, {slug: version_name})
      @versions_graph = nil
      resp.success?
    end

    # This method does not rely on the internal versionable flag of the object, instead
    # it queries Fedora directly to figure out if there are versions for the resource.
    def has_versions?
      ActiveFedora.fedora.connection.head(versions_url) 
      true
    rescue Ldp::NotFound
      false
    end

    def restore_version label
      resp = ActiveFedora.fedora.connection.patch(version_url(label), nil)
      @versions_graph = nil
      reload
      refresh_attributes if self.respond_to?("refresh_attributes")
      resp.success?
    end

    private

      def versions_request
        resp = begin
          ActiveFedora.fedora.connection.get(versions_url)
        rescue Ldp::NotFound
          return ''
        end
        if !resp.success?
          raise "unexpected return value #{resp.status} for when getting datastream content at #{uri}\n\t#{resp.body}"
        elsif resp.headers['content-type'] != 'text/turtle'
          raise "unknown response format. got '#{resp.headers['content-type']}', but was expecting 'text/turtle'"
        end
        resp.body
      end

      def version_url label
        versions_url + '/' + label
      end

      def version_name
        if versions.empty?
          "version1"
        else
          "version" + (versions.count + 1).to_s
        end
      end

      def numbered_versions statements, literals = Array.new
        statements.each do |statement|
          literals << statement.object unless statement.object.to_s.match("auto-snapshot")
        end
        return literals
      end

  end
end
