require 'mechanize'
require 'json'

class FitbitQuery

  HEADERS = {
      "User-Agent" =>  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.155 Safari/537.36",
      "Content-Type" =>  "application/x-www-form-urlencoded",
      "Accept-Encoding" =>  "gzip, deflate",
      "Accept-Language" =>  "en-US,en;q=0.8"
  }

  GROUPS = {
      "30739e34-cbe7-4a76-9a0b-5be01da2d803" => "22GDDM",
      "Planning To Run" => "22G6RX",
      "Steps Acquisition" => "22G6RW",
      "Data Super Star" => "22G6P9",
      "No Running Allowed" => "22GFJC",
      "Okinawan Dolphin Swim Team" => "22GF3D",
      "Opower Footloose" => "22GFG6",
      "Empire Steps Back" => "22GBMK",
      "NextStep" => "22G6SV",
      "Weighta-Browser" => "22GF6B",
      "Honestly, Exercising Ain't our thing?" => "22GG8Y",
      "I Hope You Step on a LEGO" => "22GFD6",
      "Oops!" => "22GCZX",
      "This is why we can't have nice things" => "22G6RC",
      "aCtivE PiGgiEs" => "22GGFP",
      "Sole Support" => "22GG6H",
      "Autobots" => "22G9PS",
      "Abnormal gait - one too many SIPS" => "22GFF8",
      "ACK's not what your network can do for you..." => "22GDSK",
      "Waka Walkers" => "22GD9P",
      "AnaFITics" => "22GDFD",
      "User Flexperience Designers" => "22GF5S",
      "Sherman's March" => "22GGC4",
      "Product Overhead" => "22GFDK",
      "Globe Trotters" => "22GDK9",
      "Secret Striders" => "22GB8W",
      "Opower MLM" => "22G6ZT",
      "Segmentation & Domination" => "22GBHS"
  }


  def run_query
    Rails.cache.fetch('groups', expires_in: 1.minute) do
      run_query_internal
    end
  end


  def run_query_internal

    mechanize = Mechanize.new

    query = {
        :_fp => "nbHlp4ln40RztQ7FkK21Ry2MI7JbqWTf",
        :_sourcePage => "s1Dp95HG-b7GrJMFkFsv6XbX0f6OV1Ndj1zeGcz7OKzA3gkNXMXGnj27D-H9WXS-",
        :disableThirdPartyLogin => "false",
        :email => "sachmaan@gmail.com",
        :includeWorkflow => "",
        :login => "Log In" ,
        :password => "lerdwirch",
        :redirect => "",
        :rememberMe => "true",
        :switchToNonSecureOnRedirect => ""

    }

    mechanize.post("https://www.fitbit.com/login", query, HEADERS)

    total_steps_hash = {}
    avg_steps_hash = {}
    num_people_hash = {}

    GROUPS.each { |team_name, group_id|
      query = {
          :request => "{\"template\":\"/ajaxTemplate.jsp\",\"serviceCalls\":[{\"name\":\"leaderboardAjaxService\",\"args\":{\"encodedGroupId\":\"#{group_id}\"},\"method\":\"getCurrentGroupGraphData\"}]}"
      }

      file = mechanize.post("https://www.fitbit.com/ajaxapi", query, HEADERS)

      response = JSON.parse(file.content)

      total_steps = response["totalSteps"].tr(',', '').to_i
      total_steps_hash[team_name] = total_steps

      team_page = mechanize.get("https://www.fitbit.com/group/#{group_id}")
      group_summary_str = team_page.at("#groupSummaryTemplate").child.content
      num_people = group_summary_str[group_summary_str.index("<li>") + 4 .. group_summary_str.index('<span class="descTxt">Members</span>') -1].strip.to_i
      num_people_hash[team_name] = num_people
      avg_steps_hash[team_name] = total_steps / num_people
    }

    sorted_results = avg_steps_hash.sort { |a,b| b[1]<=>a[1] }
    group_results = []

    count = 1
    sorted_results.each { |team_name, avg_steps|
      group_results << {
          :id => GROUPS[team_name],
          :rank => count,
          :name => team_name,
          :avg_steps => avg_steps,
          :num_people => num_people_hash[team_name],
          :total_steps => total_steps_hash[team_name]
      }
      # puts "#{count}\t#{team_name}\t#{avg_steps}\t#{num_people_hash[team_name]}\t#{total_steps_hash[team_name]}"
      count += 1
    }


    group_results

  end

end

