class GroupsController < ApplicationController

  # GET /groups
  def index
    fitbit_query = FitbitQuery.new

    @groups_with_timestamp = fitbit_query.run_query
  end

end
