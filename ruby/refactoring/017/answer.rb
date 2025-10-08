class ReportFormatter
  def initialize(data, include_header, include_total)
    @data = data
    @include_header = include_header
    @include_total = include_total
  end

  def generate
    result = []
    result << format_start
    result << format_header if @include_header && supports_header?
    result << format_body
    result << format_total if @include_total
    result << format_end
    result.compact.join(line_separator)
  end

  def format_start
    nil
  end

  def format_header
    raise NotImplementedError, "#{self.class}#format_header must be implemented"
  end

  def format_body
    raise NotImplementedError, "#{self.class}#format_body must be implemented"
  end

  def format_total
    raise NotImplementedError, "#{self.class}#format_total must be implemented"
  end

  def format_end
    nil
  end

  def supports_header?
    true
  end

  def line_separator
    "\n"
  end

  protected

  def calculate_total
    @data.sum { |item| item[:quantity] * item[:price] }
  end
end

class CsvFormatter < ReportFormatter
  def format_header
    'Product,Quantity,Price'
  end

  def format_body
    @data.map do |item|
      "#{item[:product]},#{item[:quantity]},#{item[:price]}"
    end.join("\n")
  end

  def format_total
    total = calculate_total
    "Total,,#{total}"
  end
end

class JsonFormatter < ReportFormatter
  def generate
    items = @data.map do |item|
      { product: item[:product], quantity: item[:quantity], price: item[:price] }
    end
    result = { items: items }
    if @include_total
      result[:total] = calculate_total
    end
    result.to_s
  end

  def supports_header?
    false
  end
end

class HtmlFormatter < ReportFormatter
  def format_start
    '<table>'
  end

  def format_header
    '<thead><tr><th>Product</th><th>Quantity</th><th>Price</th></tr></thead>'
  end

  def format_body
    rows = @data.map do |item|
      "<tr><td>#{item[:product]}</td><td>#{item[:quantity]}</td><td>#{item[:price]}</td></tr>"
    end
    ['<tbody>', rows, '</tbody>'].flatten.join("\n")
  end

  def format_total
    total = calculate_total
    "<tfoot><tr><td colspan='2'>Total</td><td>#{total}</td></tr></tfoot>"
  end

  def format_end
    '</table>'
  end
end

class ReportFormatterFactory
  def self.create(format, data, include_header, include_total)
    case format
    when 'csv'
      CsvFormatter.new(data, include_header, include_total)
    when 'json'
      JsonFormatter.new(data, include_header, include_total)
    when 'html'
      HtmlFormatter.new(data, include_header, include_total)
    else
      raise ArgumentError, "Unknown format: #{format}"
    end
  end
end

class ReportGenerator
  def generate_report(format, data, include_header, include_total)
    formatter = ReportFormatterFactory.create(format, data, include_header, include_total)
    formatter.generate
  end
end

data = [
  { product: 'Apple', quantity: 10, price: 100 },
  { product: 'Banana', quantity: 5, price: 50 },
  { product: 'Orange', quantity: 8, price: 80 }
]

generator = ReportGenerator.new
puts generator.generate_report('csv', data, true, true)
puts '---'
puts generator.generate_report('json', data, false, true)
puts '---'
puts generator.generate_report('html', data, true, false)
