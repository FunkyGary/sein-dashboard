class DashboardsController < ApplicationController
  before_action :authenticate_user!
  before_action :fbinformation, :only => [:index, :facebook]

  def index
    #google
    ga = GoogleAnalytics.new
    
    web_users_week = ga.web_users_week
    web_users_month = ga.web_users_month
    #官網使用者
    @web_users_week = web_users_week.first[1][0]["data"]["rows"][29]["metrics"][0]["values"][0].to_i
    @web_users_week_last_week = web_users_week.first[1][0]["data"]["rows"][22]["metrics"][0]["values"][0].to_i
    @web_users_month = web_users_month.first[1][0]["data"]["rows"][29]["metrics"][0]["values"][0].to_i
    @web_users_month_last_month = web_users_month.first[1][0]["data"]["rows"][22]["metrics"][0]["values"][0].to_i  
    @web_users_week_rate = convert_percentrate(@web_users_week, @web_users_week_last_week)  
    @web_users_month_rate = convert_percentrate(@web_users_month, @web_users_month_last_month)
    @web_users_last_7d = web_users_week.first[1][0]["data"]["rows"].flat_map{|i|i.values.second}.flat_map{|i|i.values}[23..29].flat_map{|i|i}.grep(/\d+/, &:to_i)
    @web_users_last_30d = web_users_month.first[1][0]["data"]["rows"].flat_map{|i|i.values.second}.flat_map{|i|i.values}[0..29].flat_map{|i|i}.grep(/\d+/, &:to_i)
    
    #使用者活躍度分析
    pageviews = ga.pageviews
    session_pageviews = ga.session_pageviews

    @all_users_views_last_7d_data = pageviews.first[1][0]["data"]["rows"].flat_map{|i|i.values.second}.flat_map{|i|i.values}[23..29].flat_map{|i|i}.grep(/\d+/, &:to_i)
    @all_users_views_last_30d_data = pageviews.first[1][0]["data"]["rows"].flat_map{|i|i.values.second}.flat_map{|i|i.values}[2..29].flat_map{|i|i}.grep(/\d+/, &:to_i).in_groups_of(7).flat_map{|i|i.sum}
    @single_session_pageviews_7d = session_pageviews.first[1][0]["data"]["rows"].flat_map{|i|i.values.second}.flat_map{|i|i.values}[23..29].flat_map{|i|i}.grep(/\d+/, &:to_i)
    @single_session_pageviews_30d = session_pageviews.first[1][0]["data"]["rows"].flat_map{|i|i.values.second}.flat_map{|i|i.values}[2..29].flat_map{|i|i}.grep(/\d+/, &:to_i).in_groups_of(7).flat_map{|i|i.sum}
    @activeusers_views_last_7d_data = @all_users_views_last_7d_data.zip(@single_session_pageviews_7d).map{|k| (k[0] - k[1]) }
    @activeusers_views_last_30d_data = @all_users_views_last_30d_data.zip(@single_session_pageviews_30d).map{|k| (k[0] - k[1]) }
  
    @users_activity_rate_7d = @activeusers_views_last_7d_data.zip(@all_users_views_last_7d_data).map{|k| (k[0] / k[1].to_f).round(2) }
    @users_activity_rate_30d = @activeusers_views_last_30d_data.zip(@all_users_views_last_30d_data).map{|k| (k[0] / k[1].to_f).round(2) }
    
    @ga_last_7d_date = pageviews.first[1][0]["data"]["rows"].flat_map{|i|i.values.first}[23..29].flat_map{|i|i}.flat_map { |i|i.slice(5..7)}.grep(/\d+/, &:to_i)
    @ga_last_30d_date = pageviews.first[1][0]["data"]["rows"].values_at(8,15,23,29).flat_map{|i|i.values.first}.flat_map { |i|i.slice(5..7)}.grep(/\d+/, &:to_i)
    
    #流量管道
    channel_grouping_week = ga.channel_grouping_week
    channel_grouping_month = ga.channel_grouping_month

    @channel_user_week = channel_grouping_week.first[1][0]["data"]["rows"].flat_map{|i|i.values.second}.flat_map{|i|i.values}.values_at(1,3,4,5,6).flat_map{|i|i.first}.grep(/\d+/, &:to_i)
    @channel_user_week = @channel_user_week[2], @channel_user_week[4], @channel_user_week[0], @channel_user_week[3], @channel_user_week[1]

    @bounce_rate_week = channel_grouping_week.first[1][0]["data"]["rows"].flat_map{|i|i.values.second}.flat_map{|i|i.values}.values_at(1,3,4,5,6).flat_map{|i|i.second}.grep(/\d+/, &:to_i)
    @bounce_rate_week = @bounce_rate_week[2], @bounce_rate_week[4], @bounce_rate_week[0], @bounce_rate_week[3], @bounce_rate_week[1]

    @channel_user_month = channel_grouping_month.first[1][0]["data"]["rows"].flat_map{|i|i.values.second}.flat_map{|i|i.values}.values_at(1,3,4,5,6).flat_map{|i|i.first}.grep(/\d+/, &:to_i)
    @channel_user_month = @channel_user_month[2], @channel_user_month[4], @channel_user_month[0], @channel_user_month[3], @channel_user_month[1] 

    @bounce_rate_month = channel_grouping_month.first[1][0]["data"]["rows"].flat_map{|i|i.values.second}.flat_map{|i|i.values}.values_at(1,3,4,5,6).flat_map{|i|i.second}.grep(/\d+/, &:to_i)
    @bounce_rate_month = @bounce_rate_month[2], @bounce_rate_month[4], @bounce_rate_month[0], @bounce_rate_month[3], @bounce_rate_month[1]
    
    #mailchimp
    @mail_users = MailchimpDb.last.email_sent
    @mail_users_month_rate = rate_transit(@mail_users, MailchimpDb.last(2).first.email_sent)

    @last_12w_date = []
    MailchimpDb.last(4).pluck(:date).each do |d|
      @last_12w_date << d.strftime("%m%d").to_i
    end
    @mail_users_last_30d = MailchimpDb.last(4).pluck(:email_sent)

    @mail_views = MailchimpDb.last(4).pluck(:open)
    @mail_links= MailchimpDb.last(4).pluck(:click)

    @mail_views_rate = []
    MailchimpDb.last(4).pluck(:open_rate).each do |open|
      @mail_views_rate << open.round(2)
    end

    @mail_links_rate = []
    @mail_links.zip(@mail_views) { |a, b| @mail_links_rate << a / b.to_f }

    #alexa
    @rank = AlexaDb.last(1).pluck(:womany_rank, :pansci_rank, :newsmarket_rank, :einfo_rank, :sein_rank, :npost_rank)[0]
    @rate = AlexaDb.last(1).pluck(:womany_bounce_rate, :pansci_bounce_rate, :newsmarket_bounce_rate, :einfo_bounce_rate, :sein_bounce_rate, :npost_bounce_rate)[0]
  end

  def facebook
    # fb gender
    @fans_gender_age = @graph.get_object("278666028863859/insights/page_fans_gender_age?fields=values")
    @fans_gender = @fans_gender_age.first.first.second.first['value']
    @fans_female = @fans_gender.values[0..6].inject(0, :+)
    @fans_male = @fans_gender.values[7..13].inject(0, :+)
    @fans_13_17 = @fans_gender.values.values_at(0,7).inject(0, :+)
    @fans_18_24 = @fans_gender.values.values_at(1,8).inject(0, :+)
    @fans_25_34 = @fans_gender.values.values_at(2,9).inject(0, :+)
    @fans_35_44 = @fans_gender.values.values_at(3,10).inject(0, :+)
    @fans_45_54 = @fans_gender.values.values_at(4,11).inject(0, :+)
    @fans_55_64 = @fans_gender.values.values_at(5,12).inject(0, :+)
    @fans_65 = @fans_gender.values.values_at(6,13).inject(0, :+)
    @fans_age = []
    @fans_age.push(@fans_13_17).push(@fans_18_24).push(@fans_25_34).push(@fans_35_44).push(@fans_45_54).push(@fans_55_64).push(@fans_65)
    # negative users
    @negativeusers = @graph.get_object("278666028863859/insights/page_negative_feedback_unique?fields=values&date_preset=last_30d")
    @negative_users_week = @negativeusers.second['values'].flat_map{ |i|i.values.first }[28]
    @negative_users_month = @negativeusers.third['values'].flat_map{ |i|i.values.first }[28]     
    @negative_users_week_last_week = @negativeusers.second['values'].flat_map{ |i|i.values.first }[21]
    @negative_users_month_last_month = @negativeusers.third['values'].flat_map{ |i|i.values.first }[21]     
    @negative_users_week_rate = convert_percentrate(@negative_users_week, @negative_users_week_last_week) 
    @negative_users_month_rate = convert_percentrate(@negative_users_month, @negative_users_month_last_month)
    @negative_users_last_7d = @negativeusers.first['values'].flat_map{ |i|i.values.first }[22..28]
    @negative_users_last_30d = @negativeusers.first['values'].flat_map{ |i|i.values.first }

    # fans losts
    @fanslosts = @graph.get_object("278666028863859/insights/page_fan_removes_unique?fields=values&date_preset=last_30d")
    @fans_losts_last_7d_data = @fanslosts.first['values'].flat_map { |i|i.values.first }[22..28]
    @fans_losts_last_4w_data = @fanslosts.second['values'].flat_map { |i|i.values.first }.values_at(7,14,21,28)

    # link clicks
    @postenagements = @graph.get_object("278666028863859/insights/page_post_engagements?fields=values&date_preset=last_30d")
    @post_enagements_last_7d_data = @postenagements.first['values'].flat_map { |i|i.values.first }[22..28]
    @post_enagements_last_4w_data = @postenagements.second['values'].flat_map { |i|i.values.first }.values_at(7,14,21,28)
    @linkclicks = @graph.get_object("278666028863859/insights/page_consumptions_by_consumption_type?fields=values&date_preset=last_30d")
    @link_clicks_last_7d_data = @linkclicks.first['values'].flat_map { |i|i.values.first }.flat_map { |i|i.fetch('link clicks') }[22..28]
    @link_clicks_last_4w_data = @linkclicks.first['values'].flat_map { |i|i.values.first }.flat_map { |i|i.fetch('link clicks') }.values_at(7,14,21,28)
    @link_clicks_rate_7d = []
    @link_clicks_rate_7d = @post_enagements_last_7d_data.zip(@link_clicks_last_7d_data).map { |x, y| (x / y.to_f).round(2) }
    @link_clicks_rate_30d = []
    @link_clicks_rate_30d = @post_enagements_last_4w_data.zip(@link_clicks_last_4w_data).map { |x, y| (x / y.to_f).round(2) }
  
  end

  def ga
    ga = GoogleAnalytics.new
    # @user_type = ga.user_type
    # @vistor = @user_type.first[1][0]["data"]["totals"][0]["values"][0]
    # @new = @user_type.first[1][0]["data"]["rows"][0]["metrics"][0]["values"][0]
    # @old = @user_type.first[1][0]["data"]["rows"][1]["metrics"][0]["values"][0]
    # @device = ga.device
    # @tool = @device.first[1][0]["data"]["totals"][0]["values"][0]

  end

  def mailchimp
    set_time
    @campaigns = Mailchimp.campaigns(@month, @now)
    
    alexa_api

    export_xls = ExportXls.new
    
    export_xls.mailchimp_xls(@campaigns)
    export_xls.alexa_xls(@sein, @newsmarket, @pansci, @einfo, @npost, @womany)
    
    respond_to do |format|
      format.xls { send_data(export_xls.export,
        :type => "text/excel; charset=utf-8; header=present",
        :filename => "社企流#{Date.today}資料分析.xls")
      }
      format.html
    end

  end

  private

  # 上個月星期一的日期 往後推七天
  def last_month_mon
    d = Date.today
    d = d << 1
    d = d.to_s
    @last = Date.new(d[0..3].to_i, d[5..6].to_i, 1)
    while @last.strftime("%a") != "Mon"
      @last -= 1
    end
    @last = @last.strftime("%Y-%m-%d") # 格式2018-08-18
  end

  def set_time
    @now = Time.now
    @now.utc
    @month = @now - 60 * 60 * 24 * 35
    @now.strftime("%Y-%m-%d")
    @month.strftime("%Y-%m-%d")
  end

  def rate_transit(datanew, dataold)
    return ((datanew - dataold) / dataold.to_f * 10000).round(2)
  end

  def divide_date(date)
    date.split('T').first.split('-').join()[4..7].to_i 
  end

  def fbinformation

    # facebook API
    @graph = Koala::Facebook::API.new(CONFIG.FB_TOKEN)
    # facebook fans
    @fans = @graph.get_object("278666028863859/insights/page_fans?fields=values&date_preset=today").first.first.second.first["value"]
    @fans_adds = @graph.get_object("278666028863859/insights/page_fan_adds_unique?fields=values&date_preset=last_30d")
    @fans_adds_week_data = @fans_adds.second['values'].flat_map{ |i|i.values.first }[28]
    @fans_adds_month_data = @fans_adds.third['values'].flat_map{ |i|i.values.first }[28]
    @fans_adds_last_7d_data = @fans_adds.first['values'].flat_map{ |i|i.values.first }[22..28]
    @fans_adds_last_30d_data = @fans_adds.first['values'].flat_map{ |i|i.values.first }
    @fans_adds_last_4w_data = @fans_adds.second['values'].flat_map { |i|i.values.first }.values_at(7,14,21,28)
    @fans_adds_week_rate = convert_tenthousandthrate(@fans_adds_week_data, @fans)
    @fans_adds_month_rate = convert_tenthousandthrate(@fans_adds_month_data, @fans)    

    # facebook page users
    @pageusers = @graph.get_object("278666028863859/insights/page_impressions_unique?fields=values&date_preset=last_30d")
    @page_users_week = @pageusers.second['values'].flat_map{ |i|i.values.first }[28]
    @page_users_month = @pageusers.third['values'].flat_map{ |i|i.values.first }[28]     
    @page_users_week_last_week = @pageusers.second['values'].flat_map{ |i|i.values.first }[21]
    @page_users_month_last_month = @pageusers.third['values'].flat_map{ |i|i.values.first }[21]     
    @page_users_week_rate = convert_percentrate(@page_users_week, @page_users_week_last_week) 
    @page_users_month_rate = convert_percentrate(@page_users_month, @page_users_month_last_month)
    @page_users_last_7d = @pageusers.first['values'].flat_map{ |i|i.values.first }[22..28]
    @page_users_last_30d = @pageusers.first['values'].flat_map{ |i|i.values.first }

    # facebook fans retention    
    @postsusers = @graph.get_object("278666028863859/insights/page_posts_impressions_unique?fields=values&date_preset=last_30d")
    @posts_users_week = @postsusers.second['values'].flat_map{ |i|i.values.first }[28]
    @posts_users_month = @postsusers.third['values'].flat_map{ |i|i.values.first }[28]     
    @posts_users_week_last_week = @postsusers.second['values'].flat_map{ |i|i.values.first }[21]
    @posts_users_month_last_month = @postsusers.third['values'].flat_map{ |i|i.values.first }[21]     
    @posts_users_week_rate = convert_percentrate(@posts_users_week, @posts_users_week_last_week) 
    @posts_users_month_rate = convert_percentrate(@posts_users_month, @posts_users_month_last_month)
    @posts_users_last_7d = @postsusers.first['values'].flat_map{ |i|i.values.first }[22..28]
    @posts_users_last_30d = @postsusers.first['values'].flat_map{ |i|i.values.first }
    @posts_users_last_7d_data = @postsusers.first['values'].flat_map { |i|i.values.first }[22..28]
    @posts_users_last_4w_data = @postsusers.second['values'].flat_map { |i|i.values.first }.values_at(7,14,21,28)
    @fb_last_7d_date = @postsusers.first['values'].flat_map{ |i|i.values.second }[22..28].map { |i| divide_date(i) }
    @fb_last_4w_date = @postsusers.first['values'].flat_map{ |i|i.values.second }.map{ |i| divide_date(i) }.values_at(7,14,21,28)
    @enagementsusers = @graph.get_object("278666028863859/insights/page_engaged_users?fields=values&date_preset=last_30d")
    @enagements_users_last_7d_data = @enagementsusers.first['values'].flat_map { |i|i.values.first }[22..28]
    @enagements_users_last_4w_data = @enagementsusers.second['values'].flat_map { |i|i.values.first }.values_at(7,14,21,28)
    @fans_retention_rate_7d = []
    @fans_retention_rate_7d = @enagements_users_last_7d_data.zip(@posts_users_last_7d_data).map { |x, y| (x / y.to_f).round(2) }
    @fans_retention_rate_30d = []
    @fans_retention_rate_30d = @enagements_users_last_4w_data.zip(@posts_users_last_4w_data).map { |x, y| (x / y.to_f).round(2) }
  end

  def convert_tenthousandthrate(datanew,  dataold)
      return (datanew * 10000 / (dataold - datanew).to_f).round(2)
  end

  def convert_percentrate(datanew,  dataold)
    return ((datanew - dataold) / dataold.to_f * 100).round(2)
  end

  # def ga_data_week(data, s, e)
  #   data.first[1][0]["data"]["rows"].flat_map{|i|i.values.second}.flat_map{|i|i.values}[s..e].flat_map{|i|i}.grep(/\d+/, &:to_i)
  # end

  # def ga_data_month(data, z, x, c ,v)
  #   data.first[1][0]["data"]["rows"].flat_map{|i|i.values.second}.flat_map{|i|i.values}.values_at(z, x, c, v).flat_map{|i|i}.grep(/\d+/, &:to_i)
  # end

end
