require 'csv'

CSV.foreach(Rails.root.join('db', 'nasdaq-listed.csv'), headers: true, col_sep: '|') do |row|
  Stock.create!(
    symbol: row['Symbol'],
    name: row['Security Name']
  )
end
