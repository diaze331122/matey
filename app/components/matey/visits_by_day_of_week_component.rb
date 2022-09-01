require "ahoy_matey"

class Matey::VisitsByDayOfWeekComponent < ApplicationComponent
  def initialize(events:, visits:, limit: 10)

    # Query that fetches visits to calculate 
    # average visits per weekday within the current month

      sql = "select 
        visits.day_id,
        visits.day_of_week, 
        count(day_id) num_of_days, 
        sum(visits.number_of_visits) as total_number_of_visits_for_day_type, 
        cast(
          sum(visits.number_of_visits) as FLOAT
        )/ count(day_id) as num_visits_per_day 
        from 
        (
          select 
            strftime('%w', started_at) as day_id, 
            case cast (
              strftime('%w', started_at) as integer
            ) when 0 then 'Sunday' when 1 then 'Monday' when 2 then 'Tuesday' when 3 then 'Wednesday' when 4 then 'Thursday' when 5 then 'Friday' else 'Saturday' end as day_of_week, 
            date(started_at) as date, 
            count(*) as number_of_visits 
          from 
            ahoy_visits
          where 
            date(started_at) >= date('now','localtime','start of month') and date(started_at) <= date('now','start of month','+1 month','-1 day') 
          group by 
            date(started_at)
        ) as visits 
        group by 
        visits.day_id      
      "

      @day_visits = ActiveRecord::Base.connection.execute(sql)
  end
end