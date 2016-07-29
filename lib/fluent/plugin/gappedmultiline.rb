require 'fluent/parser'

module Fluent
  module Plugin
    class MultilineParser < Parser
      def check_format_regexp(format, key)
        if format[0] == '/' && format[-1] == '/'
          begin
            Regexp.new(format[1..-2], Regexp::MULTILINE)
          rescue => e
            raise ConfigError, "Invalid regexp in #{key}: #{e}"
          end
        else
          raise ConfigError, "format should be Regexp, need //, in #{key}: '#{format}'"
        end
      end
    end
  end
end

class Fluent::TextParser
  class GappedMultilineParser < MultilineParser

    # 謎のバグ
    # コメント In しなきゃダメ
    # Plugin.register_parser("gapped_multiline", self)
    config_param :parser_buffer_limit, :integer, :default => 1000

    def configure conf
      super
      @formats = []
      @line_buffer = ''
      (1..20).each do |num|
        format = conf["format#{num}"]
        break if format.nil?
        @formats << format[1..-2]
      end
    end

    def parse(text, &block)
      @line_buffer << text
      record = {}
      regexps = []

      @formats.each do |orig_format|
        format = orig_format.gsub(/\\k<(.*?)>/) { |_| record[$1] }

        regexp = Regexp.new(/#{format}/)
        matched = @line_buffer.match(regexp)
        return yield nil, nil if matched.nil?
        matched.names.each { |name| record[name] = matched[name] }
        regexps << regexp
      end

      regexps.each { |regexp| @line_buffer.sub!(regexp, '') }
      refresh_line_buffer
      yield Fluent::Engine.now, record
    end

    def refresh_line_buffer
      @line_buffer = @line_buffer.split("\n")[0...@parser_buffer_limit].join("\n")
    end

    def has_firstline?
      true
    end

    def firstline?(line)
      Regexp.new(@formats[0]) === line
    end
  end
end


