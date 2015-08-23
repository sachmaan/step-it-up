class GroupsController < ApplicationController

  # GET /groups
  def index

    fitbit_query = FitbitQuery.new

    @groups = fitbit_query.run_query


=begin
    @groups_hash = [
        {
            :name => "Blah",
            :avg_steps => "10000",
            :num_people => "8"
        }

    ]
=end
  end

end
