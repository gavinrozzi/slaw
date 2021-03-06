module Slaw
  module Render

    # Support for transforming XML AN documents into HTML.
    #
    # This rendering is done using XSLT stylesheets. Both an entire
    # document and fragments can be rendered.
    class HTMLRenderer

      # [Hash] A Hash of Nokogiri::XSLT objects
      attr_accessor :xslt

      def initialize
        here = File.dirname(__FILE__)

        @xslt = {
          act: Nokogiri::XSLT(File.open(File.join([here, 'xsl/act.xsl']))),
          fragment: Nokogiri::XSLT(File.open(File.join([here, 'xsl/fragment.xsl']))),
        }
      end

      # Transform an entire XML document (a Nokogiri::XML::Document object) into HTML.
      # Specify `base_url` to manage the base for relative URLs generated by
      # the transform.
      #
      # @param doc [Nokogiri::XML::Document] document to render
      # @param base_url [String] root URL for relative URLs (cannot be empty)
      #
      # @return [String]
      def render(doc, base_url='')
        params = _transform_params({'base_url' => base_url})
        _run_xslt(:act, doc, params)
      end

      # Transform just a single node and its children into HTML.
      #
      # If +elem+ has an id, we use xpath to tell the XSLT which
      # element to transform. Otherwise we copy the node into a new
      # tree and apply the XSLT to that.
      #
      # @param node [Nokogiri::XML::Node] node to render
      # @param base_url [String] root URL for relative URLs (cannot be empty)
      #
      # @return [String]
      def render_node(node, base_url='')
        params = _transform_params({'base_url' => base_url})

        if node.id
          params += ['root_elem', "//*[@id='#{node.id}']"]
          doc = node.document
        else
          # create a new document with just this element at the root
          doc = Nokogiri::XML::Document.new
          doc.root = node
          params += ['root_elem', '*']
        end

        _run_xslt(:fragment, doc, params)
      end

      def _run_xslt(xslt, doc, params)
        @xslt[xslt].transform(doc, params).to_s
      end

      def _transform_params(params)
        Nokogiri::XSLT.quote_params(params)
      end
    end
  end
end
