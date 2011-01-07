class RSpecDescribeHandler < YARD::Handlers::Ruby::Base
  handles method_call(:describe)
  
  def process
    describes = statement.parameters.first.jump(:string_content).source

    # Remove the argument list from describe "#method(a, b, &c)"
    if arguments = describes[/[#.](?:.+)(\([^)]*\))$/, 1]
      describes = describes[0, describes.length - arguments.length]
    end

    unless owner.is_a?(Hash)
      pwner = Hash[describes: describes, context: ""]
      parse_block(statement.last.last, owner: pwner)
    else
      describes = owner[:describes] + describes
      pwner = owner.merge(describes: describes)
      parse_block(statement.last.last, owner: pwner)
    end
  rescue YARD::Handlers::NamespaceMissingError
  end
end

class RSpecContextHandler < YARD::Handlers::Ruby::Base
  handles method_call(:context)

  def process
    if owner.is_a?(Hash)
      context = statement.parameters.first.jump(:string_content).source
      context = owner[:context] + context + " "

      parse_block(statement.last.last, owner: owner.merge(context: context))
    end
  rescue YARD::Handlers::NamespaceMissingError
  end
end

class RSpecItHandler < YARD::Handlers::Ruby::Base
  handles method_call(:it)
  handles method_call(:its)
  handles method_call(:specify)
  
  def process
    return unless owner.is_a?(Hash)
    return unless owner[:describes]

    node = YARD::Registry.resolve(nil, owner[:describes], true)
    spec = if statement.parameters
             statement.parameters.first.jump(:string_content).source
           else
             "untitled spec"
           end

    unless node
      # statement.file
      # statement.line
      # owner[:describes]
      return
    end

    if last = statement.last.last
      source = last.source.chomp
    else
      source = ""
    end

    (node[:specifications] ||= []) << \
      Hash[ name: owner[:context] + spec,
            file: statement.file,
            line: statement.line,
            source: source ]
  end
end