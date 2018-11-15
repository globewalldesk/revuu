class Repotask < Task
  extend RepotaskFactory
  include RepotaskController

  def initialize
  end
end
