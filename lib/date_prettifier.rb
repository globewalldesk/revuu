require 'date'

module DatePrettifier

  # From timestamp, output a human-friendly date
  def prettify_timestamp(ts)
    now = DateTime.now
    ts = DateTime.parse(ts) if ts.class == String
    sec_diff = (ts.to_time.to_i - now.to_time.to_i).abs
    # Longer than one year
    if ! ts.between?(now - 365, now + 365)
      diff = (sec_diff/(60*60*24*365.0)).round
      s = pl(diff)
      ago_from_now(ts, now, 'year', diff, s)
    # One month to a year: '2 months ago', '5 months from now'
    elsif ! ts.between?(now - 56, now + 56)
      diff = ((sec_diff * 12)/(60*60*24*365.0)).round
      s = pl(diff)
      ago_from_now(ts, now, 'month', diff, s)
    # If 7-27 days ahead or behind, e.g.: '1 week ago', '3 weeks from now'
    elsif ! ts.between?(now - 6, now + 6)
      diff = ((sec_diff/7)/(60*60*24.0)).round
      s = pl(diff)
      ago_from_now(ts, now, 'week', diff, s)
    # If yesterday or tomorrow: 'yesterday', 'tomorrow'. NOTE: "out of order".
    elsif ts.yday == now.yday - 1 || ts.yday == now.yday + 1
      (ts.yday - now.yday).positive? ? 'tomorrow' : 'yesterday'
    # If today! NOTE: Also "out of order"
    elsif ts.yday == now.yday
      'today'
    # If 2-6 days ahead or behind, e.g.: '3 days ago', '4 days from now'
    elsif ! ts.between?(now - 1, now + 1)
      diff = (sec_diff/(60*60*24.0)).ceil
      s = pl(diff)
      ago_from_now(ts, now, 'day', diff, s)
    else
      'unknown'
    end
  end

  # Simple pluralizer
  def pl(diff)
    diff > 1 ? 's' : ''
  end

  def ago_from_now(ts, now, unit, diff, s)
    ts > now ? "#{diff} #{unit}#{s} from now" : "#{diff} #{unit}#{s} ago"
  end

end

=begin
# Testing data

long_ago = DateTime.new(1970)
few_months = DateTime.new(2018, 2)
few_weeks = DateTime.new(2018, 9, 3)
few_days = DateTime.new(2018, 9, 20)
yesterday = DateTime.new(2018, 9, 22)
tomorrow = DateTime.new(2018, 9, 24)
today = DateTime.new(2018,9,23)
future = DateTime.new(2020,1,1)

puts "Long ago, it was #{prettify_timestamp(long_ago)}."
puts "Earlier this year, it was #{prettify_timestamp(few_months)}."
puts "Earlier this month, it was #{prettify_timestamp(few_weeks)}."
puts "Some days ago, it was #{prettify_timestamp(few_days)}."
puts "No, it was #{prettify_timestamp(yesterday)}."
puts "No, #{prettify_timestamp(tomorrow)}!"
puts "Too late, it's #{prettify_timestamp(today)}!!!"
puts "In the future it'll be #{prettify_timestamp(future)}."
=end
