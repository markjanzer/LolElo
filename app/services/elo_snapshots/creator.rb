class EloSnapshots
  class Creator
    def self.call
      new.call
    end
    
    def call
      League.all.each do |league|
        EloSnapshots::LeagueProcessor.new(league).call
      end
    end
  end
end