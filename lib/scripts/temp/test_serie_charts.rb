require_relative '../../../config/environment'

def test
  series_without_matches = []
  series_that_break = []
  number_of_serie = PandaScore::Serie.count

  Serie.all.each_with_index do |serie, index|
    puts "Processing serie #{serie.id} (#{index + 1}/#{number_of_serie})"
    begin 
      r = ChartData.new(serie).call

      if r[:matches].empty?
        series_without_matches << serie.id
      end
    rescue => e
      puts "Error for serie #{serie.id}: #{e.message}"
      series_that_break << serie.id
    end
  end

  puts "Series without matches: #{series_without_matches}"
  puts "Series that break: #{series_that_break}"
end

test