require_relative '../../config/environment'

Snapshot.destroy_all
EloSnapshots::Creator.call