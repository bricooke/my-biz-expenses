module Haml
  # This class is used only internally. It holds the buffer of XHTML that
  # is eventually output by Haml::Engine's to_html method. It's called
  # from within the precompiled code, and helps reduce the amount of
  # processing done within instance_eval'd code.
  class Buffer
    include Haml::Helpers

    # Set the maximum length for a line to be considered a one-liner.
    # Lines <= the maximum will be rendered on one line,
    # i.e. <tt><p>Hello world</p></tt>
    ONE_LINER_LENGTH     = 50

    # The string that holds the compiled XHTML. This is aliased as
    # _erbout for compatibility with ERB-specific code.
    attr_accessor :buffer

    # Gets the current tabulation of the document.
    def tabulation
      @real_tabs + @tabulation
    end

    # Sets the current tabulation of the document.
    def tabulation=(val)
      val = val - @real_tabs
      @tabulation = val > -1 ? val : 0
    end

    # Creates a new buffer.
    def initialize(options = {})
      @options = options
      @quote_escape = options[:attr_wrapper] == '"' ? "&quot;" : "&apos;"
      @other_quote_char = options[:attr_wrapper] == '"' ? "'" : '"'
      @buffer = ""
      @one_liner_pending = false
      @tabulation = 0

      # The number of tabs that Engine thinks we should have
      # @real_tabs + @tabulation is the number of tabs actually output
      @real_tabs = 0
    end

    # Renders +text+ with the proper tabulation. This also deals with
    # making a possible one-line tag one line or not.
    def push_text(text, tabulation, flattened = false)
      if flattened
        # In this case, tabulation is the number of spaces, rather
        # than the number of tabs.
        @buffer << "#{' ' * tabulation}#{flatten(text + "\n")}"
        @one_liner_pending = true
      elsif @one_liner_pending && one_liner?(text)
        @buffer << text
      else
        if @one_liner_pending
          @buffer << "\n"
          @one_liner_pending = false
        end
        @buffer << "#{tabs(tabulation)}#{text}\n"
      end
    end

    # Properly formats the output of a script that was run in the
    # instance_eval.
    def push_script(result, tabulation, flattened)
      if flattened
        result = Haml::Helpers.find_and_preserve(result)
      end
      unless result.nil?
        result = result.to_s
        while result[-1] == 10 # \n
          # String#chomp is slow
          result = result[0...-1]
        end
        
        result = result.gsub("\n", "\n#{tabs(tabulation)}")
        push_text result, tabulation
      end
      nil
    end

    # Takes the various information about the opening tag for an
    # element, formats it, and adds it to the buffer.
    def open_tag(name, tabulation, atomic, try_one_line, class_id, obj_ref, flattened, *attributes_hashes)
      attributes = {}
      attributes.merge!(parse_class_and_id(class_id)) unless class_id.nil? || class_id.empty?
      attributes.merge!(parse_object_ref(obj_ref, attributes[:id], attributes[:class])) if obj_ref
      attributes_hashes.each { |h| attributes.merge! h if h }

      @one_liner_pending = false
      if atomic
        str = " />\n"
      elsif try_one_line
        @one_liner_pending = true
        str = ">"
      elsif flattened
        str = ">&#x000A;"
      else
        str = ">\n"
      end
      @buffer << "#{tabs(tabulation)}<#{name}#{build_attributes(attributes)}#{str}"
      @real_tabs += 1
    end

    # Creates a closing tag with the given name.
    def close_tag(name, tabulation)
      if @one_liner_pending
        @buffer << "</#{name}>\n"
        @one_liner_pending = false
      else
        push_text("</#{name}>", tabulation)
      end
    end

    # Opens an XHTML comment.
    def open_comment(try_one_line, conditional, tabulation)
      conditional << ">" if conditional
      @buffer << "#{tabs(tabulation)}<!--#{conditional.to_s} "
      if try_one_line
        @one_liner_pending = true
      else
        @buffer << "\n"
        @real_tabs += 1
      end
    end

    # Closes an XHTML comment.
    def close_comment(has_conditional, tabulation)
      close_tag = has_conditional ? "<![endif]-->" : "-->"
      if @one_liner_pending
        @buffer << " #{close_tag}\n"
        @one_liner_pending = false
      else
        push_text(close_tag, tabulation)
      end
    end
    
    # Stops parsing a flat section.
    def stop_flat
      buffer.concat("\n")
      @one_liner_pending = false
    end

    # Some of these methods are exposed as public class methods
    # so they can be re-used in helpers.

    # Takes a hash and builds a list of XHTML attributes from it, returning
    # the result.
    def build_attributes(attributes = {})
      result = attributes.collect do |a,v|
        v = v.to_s
        unless v.nil? || v.empty?
          attr_wrapper = @options[:attr_wrapper]
          if v.include? attr_wrapper
            if v.include? @other_quote_char
              v = v.gsub(attr_wrapper, @quote_escape)
            else
              attr_wrapper = @other_quote_char
            end
          end
          " #{a}=#{attr_wrapper}#{v}#{attr_wrapper}"
        end
      end
      result.sort.join
    end

    private

    # Gets <tt>count</tt> tabs. Mostly for internal use.
    def tabs(count)
      @real_tabs = count
      '  ' * (count + @tabulation)
    end

    # Iterates through the classes and ids supplied through <tt>.</tt>
    # and <tt>#</tt> syntax, and returns a hash with them as attributes,
    # that can then be merged with another attributes hash.
    def parse_class_and_id(list)
      attributes = {}
      list.scan(/([#.])([-_a-zA-Z0-9]+)/) do |type, property|
        case type
        when '.'
          if attributes[:class]
            attributes[:class] += " "
          else
            attributes[:class] = ""
          end
          attributes[:class] += property
        when '#'
          attributes[:id] = property
        end
      end
      attributes
    end

    # Takes an array of objects and uses the class and id of the first
    # one to create an attributes hash.
    def parse_object_ref(ref, old_id, old_class)
      ref = ref[0]
      # Let's make sure the value isn't nil. If it is, return the default Hash.
      return {} if ref.nil?
      class_name = underscore(ref.class)
      id = "#{class_name}_#{ref.id}"

      if old_class
        class_name += " #{old_class}"
      end

      if old_id
        id = "#{old_id}_#{id}"
      end

      {:id => id, :class => class_name}
    end

    # Returns whether or not the given value is short enough to be rendered
    # on one line.
    def one_liner?(value)
      value.length <= ONE_LINER_LENGTH && value.scan(/\n/).empty?
    end

    # Changes a word from camel case to underscores.
    # Based on the method of the same name in Rails' Inflector,
    # but copied here so it'll run properly without Rails.
    def underscore(camel_cased_word)
      camel_cased_word.to_s.gsub(/::/, '_').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
    end
  end
end

unless String.methods.include? 'old_comp'
  class String # :nodoc
    alias_method :old_comp, :<=>
    
    def <=>(other)
      if other.is_a? NilClass
        -1
      else
        old_comp(other)
      end
    end
  end
    
  class NilClass # :nodoc:
    include Comparable
    
    def <=>(other)
      other.nil? ? 0 : 1
    end
  end
end

