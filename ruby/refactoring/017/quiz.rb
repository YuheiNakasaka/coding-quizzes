class ReportGenerator
  def generate_report(format, data, include_header, include_total)
    if format == 'csv'
      result = []
      result << 'Product,Quantity,Price' if include_header
      data.each do |item|
        result << "#{item[:product]},#{item[:quantity]},#{item[:price]}"
      end
      if include_total
        total = data.sum { |item| item[:quantity] * item[:price] }
        result << "Total,,#{total}"
      end
      result.join("\n")
    elsif format == 'json'
      items = data.map do |item|
        { product: item[:product], quantity: item[:quantity], price: item[:price] }
      end
      result = { items: items }
      if include_total
        total = data.sum { |item| item[:quantity] * item[:price] }
        result[:total] = total
      end
      result.to_s
    elsif format == 'html'
      result = ['<table>']
      result << '<thead><tr><th>Product</th><th>Quantity</th><th>Price</th></tr></thead>' if include_header
      result << '<tbody>'
      data.each do |item|
        result << "<tr><td>#{item[:product]}</td><td>#{item[:quantity]}</td><td>#{item[:price]}</td></tr>"
      end
      result << '</tbody>'
      if include_total
        total = data.sum { |item| item[:quantity] * item[:price] }
        result << "<tfoot><tr><td colspan='2'>Total</td><td>#{total}</td></tr></tfoot>"
      end
      result << '</table>'
      result.join("\n")
    else
      raise ArgumentError, "Unknown format: #{format}"
    end
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
