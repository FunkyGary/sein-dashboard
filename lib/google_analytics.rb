require 'google/apis/analyticsreporting_v4'
require "googleauth"

class GoogleAnalytics

  include Google::Apis::AnalyticsreportingV4

  mattr_accessor :credentials
  mattr_accessor :analytics

  def initialize
    self.credentials = 
      Google::Auth::UserRefreshCredentials.new(
      client_id: CONFIG.GOOGLE_API_KEY,
      client_secret: CONFIG.GOOGLE_API_SECRET,
      scope: ["https://www.googleapis.com/auth/analytics.readonly"],
      additional_parameters: { "access_type" => "offline" })

    self.credentials.refresh_token = CONFIG.GOOGLE_REFRESH_TOKEN
    self.credentials.fetch_access_token!

    self.analytics = AnalyticsReportingService.new
    self.analytics.authorization = self.credentials
  end

  def web_users_week
    
    request = GetReportsRequest.new(
      { report_requests: [
            { metrics: [{ expression: "ga:7dayUsers" }],
             dimensions: [{ name: "ga:date" }],
             date_ranges: [{ start_date: "30daysAgo", 
                           end_date: "today"}],
             view_id: "ga:55621750"
      }]})
    return convert(request)

  end

  def web_users_month

    request = GetReportsRequest.new(
      { report_requests: [
            { metrics: [{ expression: "ga:30dayUsers" }],
             dimensions: [{ name: "ga:date" }],
             date_ranges: [{ start_date: "30daysAgo", 
                           end_date: "today"}],
             view_id: "ga:55621750"
      }]})

    return convert(request)

  end

  def pageviews
    request = GetReportsRequest.new(
      { report_requests: [
            { metrics: [{ expression: "ga:pageviews" }],
             dimensions: [{ name: "ga:date" }],
             date_ranges: [{ start_date: "30daysAgo", 
                           end_date: "today" }],
             view_id: "ga:55621750" 
      }]})
    return convert(request)
  end


  def session_pageviews
    request = GetReportsRequest.new(
      { report_requests: [
            { view_id: "ga:55621750",
              page_size: 31,
              metrics: [{ expression: "ga:pageviews" }],
             dimensions: [{ name: "ga:sessionCount" }, { name: "ga:date" }],
             date_ranges: [{ start_date: "30daysAgo", 
                           end_date: "today" }]
                  
      }]})
    return convert(request)
  end

  

  def channel_grouping_week
    
    request = GetReportsRequest.new(
      { report_requests: [
            { metrics: [{ expression: "ga:users" }, { expression: "ga:bounceRate" }],
             dimensions: [{ name: "ga:channelGrouping"}],
             date_ranges: [{ start_date: "7daysAgo", 
                           end_date: "today"}],
             view_id: "ga:55621750" 
      }]})
    return convert(request)
  end

  

  def channel_grouping_month
    request = GetReportsRequest.new(
      { report_requests: [
            { metrics: [{ expression: "ga:users" }, { expression: "ga:bounceRate" }],
             dimensions: [{ name: "ga:channelGrouping"}],
             date_ranges: [{ start_date: "30daysAgo", 
                           end_date: "today"}],
             view_id: "ga:55621750" 
      }]})
    return convert(request)
  end

  def user_age_bracket_week
    request = GetReportsRequest.new(
      { report_requests: [
            { metrics: [{ expression: "ga:users" }],
             dimensions: [ { name: "ga:userAgeBracket" }],
             date_ranges: [ { start_date: "7daysAgo", 
                           end_date: "yesterday"} ],
             view_id: "ga:55621750" ,          
      }]})
    return convert(request) 
  end

  def user_age_bracket_month
    request = GetReportsRequest.new(
      { report_requests: [
            { metrics: [{ expression: "ga:users" }],
             dimensions: [ { name: "ga:userAgeBracket" }],
             date_ranges: [ { start_date: "30daysAgo", 
                           end_date: "yesterday"} ],
             view_id: "ga:55621750" ,          
      }]})
    return convert(request) 
  end

  
  
  def user_type
    request = GetReportsRequest.new(
      { report_requests: [
            { metrics: [{ expression: "ga:users" }],
             dimensions: [{ name: "ga:userType" }],
             date_ranges: [{ start_date: "today", 
                           end_date: "today"}],
             view_id: "ga:55621750" 
      }]})
    return convert(request)
  end

  def user_gender
    request = GetReportsRequest.new(
      { report_requests: [
            { metrics: [{ expression: "ga:users" }],
             dimensions: [ { name: "ga:userGender" }],
             date_ranges: [ { start_date: "today", 
                           end_date: "today"} ],
             view_id: "ga:55621750" 
      }]})
    return convert(request) 
  end

  def user_type_month
    request = GetReportsRequest.new(
      { report_requests: [
            { metrics: [{ expression: "ga:users" }],
             dimensions: [{ name: "ga:userType" }],
             date_ranges: [{ start_date: "30daysAgo", 
                           end_date: "today"}],
             view_id: "ga:55621750" 
      }]})
    return convert(request)
  end
  
  #網站瀏覽量


  

  

  #excel資料

  #網站總造訪人數
  def users_day
    request = GetReportsRequest.new(
      { report_requests: [
            { metrics: [{ expression: "ga:users" }],
              dimensions: [{ name: "ga:date" }],
             date_ranges: [{ start_date: "365daysAgo", 
                           end_date: "yesterday"}],
             view_id: "ga:55621750"
      }]})
    return convert(request)
  end

  def sessions_day
    request = GetReportsRequest.new(
      { report_requests: [
            { metrics: [{ expression: "ga:sessions"}],
             dimensions: [{ name: "ga:date" }],
             date_ranges: [{ start_date: "365daysAgo", 
                           end_date: "yesterday"}],
             view_id: "ga:55621750"
      }]})
    return convert(request)
  end

  def avg_time_on_page_day
    request = GetReportsRequest.new(
      { report_requests: [
            { metrics: [{ expression: "ga:avgTimeOnPage"}],
             dimensions: [{ name: "ga:date" }],
             date_ranges: [{ start_date: "365daysAgo", 
                           end_date: "yesterday"}],
             view_id: "ga:55621750"
      }]})
    return convert(request)
  end

  def channel_grouping_day_1
    
    request = GetReportsRequest.new(
      { report_requests: [
            { metrics: [{ expression: "ga:users" }],
             dimensions: [{ name: "ga:channelGrouping"},{name:"ga:date"}],
             date_ranges: [{ start_date: "365daysAgo", 
                           end_date: "yesterday"}],
             view_id: "ga:55621750" 
      }]})
    return convert(request)
  end

  def channel_grouping_day_2
    
    request = GetReportsRequest.new(
      { report_requests: [
            { metrics: [{ expression: "ga:users" }],
             dimensions: [{ name: "ga:channelGrouping"},{name:"ga:date"}],
             date_ranges: [{ start_date: "365daysAgo", 
                           end_date: "yesterday"}],
             view_id: "ga:55621750", 
             page_token: "1000"
      }]})
    return convert(request)
  end

  def bounce_rate_day
    request = GetReportsRequest.new(
      { report_requests: [
            { metrics: [{ expression: "ga:bounceRate" }],
             dimensions: [{name:"ga:date"}],
             date_ranges: [{ start_date: "365daysAgo", 
                           end_date: "yesterday"}],
             view_id: "ga:55621750" 
      }]})
    return convert(request)
  end


  #工作階段
  def sessions_week
    request = GetReportsRequest.new(
      { report_requests: [
            { metrics: [{ expression: "ga:sessions" }],
             dimensions: [{ name: "ga:date" }],
             date_ranges: [{ start_date: "7daysAgo", 
                           end_date: "today"}],
             view_id: "ga:55621750"
      }]})
    return convert(request)
  end

  def sessions_month
    request = GetReportsRequest.new(
      { report_requests: [
            { metrics: [{ expression: "ga:sessions" }],             
             date_ranges: [{ start_date: "30daysAgo", 
                           end_date: "today"}],
             view_id: "ga:55621750"
      }]})
    return convert(request)
  end
  

  #不重複訪客
  def active_user_day
    request = GetReportsRequest.new(
      { report_requests: [
            { metrics: [{ expression: "ga:7dayUsers" }], 
              dimensions: [{ name: "ga:date" }],            
             date_ranges: [{ start_date: "365daysAgo", 
                           end_date: "yesterday"}],
             view_id: "ga:55621750"
      }]})
    return convert(request)
  end


  #ga:7dayUsers
  #ga:30dayUsers

  #新訪客(只造訪一次)
  #回訪客(來2次以上)
  #回訪客比例

  def user_type_day
    request = GetReportsRequest.new(
      { report_requests: [
            { metrics: [{ expression: "ga:users" }],
             dimensions: [{ name: "ga:userType" },{ name: "ga:date" }],
             date_ranges: [{ start_date: "365daysAgo", 
                           end_date: "yesterday"}],
             view_id: "ga:55621750" 
      }]})
    return convert(request)
  end

  def pageviews_day
    request = GetReportsRequest.new(
      { report_requests: [
            { metrics: [{ expression: "ga:pageviews" }],
              dimensions: [{ name: "ga:date" }],
             date_ranges: [{ start_date: "365daysAgo", 
                           end_date: "yesterday"}],
             view_id: "ga:55621750" 
      }]})
    return convert(request)
  end




  #平均停留時間
  def avg_session_duration_day
    request = GetReportsRequest.new(
      { report_requests: [
            { metrics: [{ expression: "ga:avgSessionDuration", formatting_Type: "FLOAT"}],
             dimensions: [ { name: "ga:date" }],
             date_ranges: [ { start_date: "365daysAgo", 
                           end_date: "yesterday"}],
             view_id: "ga:55621750" 
      }]})
    return convert(request) 
  end

  #星期幾最多訪客

  def week_name_users
    request = GetReportsRequest.new(
      { report_requests: [
            { metrics: [{ expression: "ga:users" }],
             dimensions: [ { name: "ga:dayOfWeekName" }],
             date_ranges: [ { start_date: "60daysAgo", 
                           end_date: "today"}],
             view_id: "ga:55621750" 
      }]})
    return convert(request) 
  end
  #
  #

  #平均網頁停留時間
  def week_name_users_week
    request = GetReportsRequest.new(
      { report_requests: [
            { metrics: [{ expression: "ga:avgTimeOnPage" }],
             dimensions: [ { name: "ga:dayOfWeekName" }],
             date_ranges: [ { start_date: "7daysAgo", 
                           end_date: "today"}],
             view_id: "ga:55621750" 
      }]})
    return convert(request) 
  end

  def week_name_users_month
    request = GetReportsRequest.new(
      { report_requests: [
            { metrics: [{ expression: "ga:avgTimeOnPage" }],
             dimensions: [ { name: "ga:dayOfWeekName" }],
             date_ranges: [ { start_date: "30daysAgo", 
                           end_date: "today"}],
             view_id: "ga:55621750" 
      }]})
    return convert(request) 
  end
  def user_age_bracket_3
    request = GetReportsRequest.new(
      { report_requests: [
            { metrics: [{ expression: "ga:users" }],
             dimensions: [ { name: "ga:userAgeBracket" }, { name: "ga:date" }],
             date_ranges: [ { start_date: "365daysAgo", 
                           end_date: "yesterday"} ],
             view_id: "ga:55621750" ,
             page_token:"2000"
      }]})
    return convert(request) 
  end

  def user_age_bracket_2
    request = GetReportsRequest.new(
      { report_requests: [
            { metrics: [{ expression: "ga:users" }],
             dimensions: [ { name: "ga:userAgeBracket" }, { name: "ga:date" }],
             date_ranges: [ { start_date: "365daysAgo", 
                           end_date: "yesterday"} ],
             view_id: "ga:55621750" ,
             page_token:"1000"
      }]})
    return convert(request) 
  end
  def user_age_bracket_1
    request = GetReportsRequest.new(
      { report_requests: [
            { metrics: [{ expression: "ga:users" }],
             dimensions: [ { name: "ga:userAgeBracket" }, { name: "ga:date" }],
             date_ranges: [ { start_date: "365daysAgo", 
                           end_date: "yesterday"} ],
             view_id: "ga:55621750" ,
             
      }]})
    return convert(request) 
  end


  def user_gender_day
    request = GetReportsRequest.new(
      { report_requests: [
            { metrics: [{ expression: "ga:users" }],
             dimensions: [ { name: "ga:userGender" }, { name: "ga:date" }],
             date_ranges: [ { start_date: "365daysAgo", 
                           end_date: "yesterday"} ],
             view_id: "ga:55621750" 
      }]})
    return convert(request) 
  end

  #平均瀏覽頁數
  #每次工作階段頁數

  def pageviews_per_session_day                  
    request = GetReportsRequest.new(
      { report_requests: [
            { metrics: [{ expression: "ga:pageviewsPerSession" }],
             dimensions: [{ name: "ga:date" }],
             date_ranges: [{ start_date: "30daysAgo", 
                           end_date: "today"}],
             view_id: "ga:55621750" 
      }]})
    return convert(request)
  end

  #官網使用裝置分析
  def device_1
    request = GetReportsRequest.new(
      { report_requests: [
        { metrics: [{ expression: "ga:users" }],
         dimensions: [{ name: "ga:deviceCategory" },{ name: "ga:date" }],
         date_ranges: [{ start_date: "365daysAgo", 
                           end_date: "yesterday"}],
         view_id: "ga:55621750" 
      }]})
    return convert(request)
  end
  def device_2
    request = GetReportsRequest.new(
      { report_requests: [
        { metrics: [{ expression: "ga:users" }],
         dimensions: [{ name: "ga:deviceCategory" },{ name: "ga:date" }],
         date_ranges: [{ start_date: "365daysAgo", 
                           end_date: "yesterday"}],
         view_id: "ga:55621750" ,
         page_token: "1000"
      }]})
    return convert(request)
  end


  private

  def convert(request)
    response = analytics.batch_get_reports(request)
    JSON.parse(response.to_json)
  end

end
