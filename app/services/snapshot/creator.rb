class Snapshot
  class Creator
    def self.call
      new.call
    end
    
    def call
      League.all.each do |league|
        League::CreateSnapshots.new(league).call
      end
    end
  end
end