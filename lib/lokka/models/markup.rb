module Markup
  require 'rouge'
  require 'rouge/plugins/redcarpet'

  class RedcarpetWithRougeRenderHTML < Redcarpet::Render::HTML
    include Rouge::Plugins::Redcarpet
  end

  class << self
    attr_accessor :engine_list

    def use_engine(name, text)
      @engine_list.each do |engine|
        return engine[2].call(text) if engine[0] == name
      end
      text
    end
  end

  @engine_list = [
      ['html', 'HTML', lambda{ |text| text }],
      ['kramdown', 'Markdown (Kramdown)',
        lambda do |text|
          Kramdown::Document.new(text,
                                 :coderay_line_numbers => nil,
                                 :coderay_css => :class
                                ).to_html()
        end
      ],
      ['redcloth', 'Textile (Redcloth)',
        lambda{ |text| RedCloth.new(text).to_html }],
      ['wikicloth', 'MediaWiki (WikiCloth)',
        lambda{ |text| WikiCloth::Parser.new(:data => text).to_html(:noedit => true) }],
      ['redcarpet', 'Markdown (redcarpet)',
        lambda do |text|
          Redcarpet::Markdown.new(
            RedcarpetWithRougeRenderHTML.new(escape_html:true),
            disable_indented_code_blocks: true,
            :fenced_code_blocks  => true,
            :autolink            => true
          ).render(text)
        end]
  ]
end
