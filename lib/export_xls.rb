class ExportXls

  mattr_accessor :xls_report
  mattr_accessor :book
  mattr_accessor :head
  mattr_accessor :percent
  mattr_accessor :center
  mattr_accessor :left

  def initialize
    self.xls_report = StringIO.new
    self.book = Spreadsheet::Workbook.new 

    self.head = Spreadsheet::Format.new :pattern_fg_color => :orange, :vertical_align => :center, 
    :weight => :bold, :size => 14, :pattern => 1, :horizontal_align => :center
    self.percent = Spreadsheet::Format.new :number_format => '##.##%', :horizontal_align => :center
    self.center = Spreadsheet::Format.new :horizontal_align => :center, :vertical_align => :center
    self.left = Spreadsheet::Format.new :horizontal_align => :left, :vertical_align => :center


    @sheet1 = book.create_worksheet :name => "FB"
    @sheet1.default_format = center
    @sheet2 = book.create_worksheet :name => "GA"
    @sheet2.default_format = center
    @sheet3 = book.create_worksheet :name => "Mailchimp&Alexa"
    @sheet3.default_format = center
  end

  def fb_xls(data)
    @sheet1.row(0).set_format(0, head)
    @sheet1[0, 0] = "FB各項指標"
    @sheet1[1, 0] = "日期"
    @sheet1[2, 0] = "總粉絲數"
    @sheet1[3, 0] = "粉絲淨讚數"
    @sheet1[4, 0] = "粉絲退讚數"
    @sheet1[5, 0] = "粉絲專頁總觸及人數"
    @sheet1[6, 0] = "PO文互動數\nPO文心情、留言、分享加總"
    @sheet1[7, 0] = "PO文互動人數"
    @sheet1[8, 0] = "負面行動次數"
    @sheet1[9, 0] = "連結點擊次數"
    @sheet1.column(0).width = 20

    i = 0
    c = 1
    4.times do #to-do flex
      @sheet1.row(0).set_format(c, head)
      @sheet1[0, c] = "week#{c}"
      @sheet1[1, c] = "#{data[i].date.strftime("%m-%d")}-#{data[i+6].date.strftime("%Y-%m-%d")}"
      @sheet1[2, c] = data[i+6].fans
      @sheet1[3, c] = data[i+6].fans_adds_week
      @sheet1[4, c] = data[i+6].fans_losts_week
      @sheet1[5, c] = data[i+6].page_users_week
      @sheet1[6, c] = data[i+6].posts_users_week
      @sheet1[7, c] = data[i+6].post_enagements_week
      @sheet1[8, c] = data[i+6].negative_users_week
      @sheet1[9, c] = data[i+6].link_clicks_week

      i += 7
      c += 1
    end
  end

  def ga_xls(data) # to-do week data
    @sheet2.row(0).set_format(0, head)
    @sheet2[0, 0] = "GA各項指標"
    @sheet2[1, 0] = "日期"
    @sheet2[2, 0] = "工作階段"
    @sheet2[3, 0] = "不重複訪客"
    @sheet2[4, 0] = "新訪客(只造訪一次)"
    @sheet2[5, 0] = "回訪客(來2次以上)"
    @sheet2[6, 0] = "回訪客比例"
    @sheet2[7, 0] = "網站瀏覽量"
    @sheet2[8, 0] = "平均瀏覽頁數"
    @sheet2[9, 0] = "平均停留時間"
    @sheet2[10, 0] = "星期幾最多訪客"
    @sheet2[11, 0] = "平均網頁停留時間"
    @sheet2.merge_cells(12, 0, 13, 0)
    @sheet2[12, 0] = "流量管道：有機搜尋"
    @sheet2.merge_cells(14, 0, 15, 0)
    @sheet2[14, 0] = "流量管道：社群媒體(FB為主)"
    @sheet2.merge_cells(16, 0, 17, 0)
    @sheet2[16, 0] = "流量管道：直接流量\n(網址/我的最愛/EDM)"
    @sheet2.merge_cells(18, 0, 19, 0)
    @sheet2[18, 0] = "流量管道：推薦連結"
    @sheet2.merge_cells(20, 0, 21, 0)
    @sheet2[20, 0] = "年齡分佈\n（18-24歲）"
    @sheet2.merge_cells(22, 0, 23, 0)
    @sheet2[22, 0] = "（25-34歲）"
    @sheet2.merge_cells(24, 0, 25, 0)
    @sheet2[24, 0] = "（35-44歲）"
    @sheet2.merge_cells(26, 0, 27, 0)
    @sheet2[26, 0] = "（45-54歲）"
    @sheet2[28, 0] = "性別（男性）"
    @sheet2[29, 0] = "（女性）"

    @sheet2.column(0).width = 20

    i = 0
    c = 1
    4.times do #to-do flex
      all_user = data[i..i+6].pluck(:user_18_24, :user_25_34, :user_35_44, :user_45_54, :user_55_64, :user_65).reduce(:+).reduce(:+)
      gender = data[i..i+6].pluck(:female_user, :male_user).reduce(:+).reduce(:+)

      @sheet2.row(0).set_format(c, head)
      @sheet2[0, c] = "week#{c}"
      @sheet2[1, c] = "#{data[i].date.strftime("%m-%d")}-#{data[i+6].date.strftime("%Y-%m-%d")}"
      @sheet2[2, c] = data[i..i+6].pluck(:sessions_day).reduce(:+)
      @sheet2[3, c] = data[i+6].web_users_month
      @sheet2[4, c] = data[i..i+6].pluck(:new_visitor).reduce(:+)
      @sheet2[5, c] = data[i..i+6].pluck(:return_visitor).reduce(:+)
      @sheet2[6, c] = data[i..i+6].pluck(:return_visitor).reduce(:+) / (data[i..i+6].pluck(:return_visitor).reduce(:+) + data[i..i+6].pluck(:new_visitor).reduce(:+)).to_f
      @sheet2[7, c] = data[i..i+6].pluck(:pageviews_day).reduce(:+)
      @sheet2[8, c] = data[i..i+6].pluck(:pageviews_per_session_day).reduce(:+) / 7
      @sheet2[9, c] = data[i..i+6].pluck(:avg_session_duration_day).reduce(:+) / 7
      @sheet2[10, c] = data[i..i+6].pluck(:sessions_day, :date).max[1].strftime("%a")
      @sheet2[11, c] = data[i..i+6].pluck(:avg_time_on_page_day).reduce(:+) / 7
      @sheet2[12, c] = data[i..i+6].pluck(:oganic_search_day).reduce(:+)
      @sheet2[13, c] = data[i..i+6].pluck(:oganic_search_bounce).reduce(:+) / 7
      @sheet2[14, c] = data[i..i+6].pluck(:social_user_day).reduce(:+)
      @sheet2[15, c] = data[i..i+6].pluck(:social_user_day).reduce(:+) / 7
      @sheet2[16, c] = data[i..i+6].pluck(:direct_user_day).reduce(:+)
      @sheet2[17, c] = data[i..i+6].pluck(:direct_user_day).reduce(:+) / 7
      @sheet2[18, c] = data[i..i+6].pluck(:referral_user_day).reduce(:+)
      @sheet2[19, c] = data[i..i+6].pluck(:referral_user_day).reduce(:+) / 7
      @sheet2.row(20).set_format(c, percent)
      @sheet2[20, c] = data[i..i+6].pluck(:user_18_24).reduce(:+) / all_user.to_f
      @sheet2[21, c] =  data[i..i+6].pluck(:user_18_24).reduce(:+)
      @sheet2.row(22).set_format(c, percent)
      @sheet2[22, c] = data[i..i+6].pluck(:user_25_34).reduce(:+) / all_user.to_f
      @sheet2[23, c] = data[i..i+6].pluck(:user_25_34).reduce(:+)
      @sheet2.row(24).set_format(c, percent)
      @sheet2[24, c] = data[i..i+6].pluck(:user_35_44).reduce(:+) / all_user.to_f
      @sheet2[25, c] = data[i..i+6].pluck(:user_35_44).reduce(:+)
      @sheet2.row(26).set_format(c, percent)
      @sheet2[26, c] = data[i..i+6].pluck(:user_45_54).reduce(:+) / all_user.to_f
      @sheet2[27, c] = data[i..i+6].pluck(:user_45_54).reduce(:+)
      @sheet2.row(28).set_format(c, percent)
      @sheet2.row(29).set_format(c, percent)
      @sheet2[28, c] = data[i..i+6].pluck(:male_user).reduce(:+) / gender.to_f
      @sheet2[29, c] = data[i..i+6].pluck(:female_user).reduce(:+) / gender.to_f

      i += 7
      c += 1
    end
  end

  def mailchimp_xls(data)
    data = data.pluck(:date, :email_sent, :title, :open, :open_rate, :click, :most_click_title, :most_click_time)

    @sheet3.row(0).set_format(0, head)
    @sheet3[0, 0] = "電子報"
    @sheet3[1, 0] = "發佈日期"
    @sheet3[2, 0] = "訂閱數"
    @sheet3[3, 0] = "電子報標題"
    @sheet3.merge_cells(4, 0, 5, 0)
    @sheet3[4, 0] = "信件點開（次數/佔比）"
    @sheet3.merge_cells(6, 0, 7, 0)
    @sheet3[6, 0] = "連結點擊率（次數/佔比）"
    @sheet3.merge_cells(8, 0, 9, 0)
    @sheet3[8, 0] = "最多點擊文章（標題/次數）"
    @sheet3.column(0).width = 20

    i = 1
    data.each do |d|
      @sheet3.row(0).set_format(i, head)
      @sheet3[0, i] = "week#{i}"
      @sheet3[1, i] = d[0].strftime("%Y-%m-%d")
      @sheet3[2, i] = d[1]
      @sheet3.row(3).set_format(i, left)
      @sheet3[3, i] = d[2].split('】').second
      @sheet3[4, i] = d[3]
      @sheet3.row(5).set_format(i, percent)
      @sheet3[5, i] = d[4]
      @sheet3[6, i] = d[5]
      @sheet3.row(7).set_format(i, percent)
      @sheet3[7, i] = d[5] / d[3].to_f
      @sheet3.row(8).set_format(i, left)
      @sheet3[8, i] = d[6]
      @sheet3[9, i] = d[7]
      @sheet3.column(i).width = 20

      i += 1
    end
  end

  def alexa_xls(data)
    @sheet3.merge_cells(12, 0, 12, 5)
    @sheet3.row(12).set_format(0, head)
    @sheet3[12, 0] = "競爭媒體排名"

    @sheet3[13, 0] = "其他媒體"
    @sheet3[13, 1] = "網址"
    @sheet3[13, 2] = "國內排名"
    @sheet3[13, 3] = "跳出率"
    @sheet3[13, 4] = "每日每人瀏覽頁數"
    @sheet3[13, 5] = "每日每人停留時間"
    @sheet3.column(1).width = 20
    @sheet3.column(2).width = 20
    @sheet3.column(3).width = 20
    @sheet3.column(4).width = 20
    @sheet3.column(5).width = 20

    @sheet3[14, 0] = "社企流"
    @sheet3[15, 0] = "上下游"
    @sheet3[16, 0] = "泛科學"
    @sheet3[17, 0] = "環境資訊中心"
    @sheet3[18, 0] = "NPOst"
    @sheet3[19, 0] = "Womany"

    @sheet3[14, 1] = "http://www.seinsights.asia/"
    @sheet3[15, 1] = "http://www.newsmarket.com.tw/"
    @sheet3[16, 1] = "http://pansci.asia/"
    @sheet3[17, 1] = "http://e-info.org.tw/"
    @sheet3[18, 1] = "http://npost.tw/"
    @sheet3[19, 1] = "http://womany.net/"

    @sheet3[14, 2] = data.sein_rank
    @sheet3[15, 2] = data.newsmarket_rank
    @sheet3[16, 2] = data.pansci_rank
    @sheet3[17, 2] = data.einfo_rank
    @sheet3[18, 2] = data.npost_rank
    @sheet3[19, 2] = data.womany_rank

    @sheet3.row(14).set_format(3, percent)
    @sheet3[14, 3] = data.sein_bounce_rate
     @sheet3.row(15).set_format(3, percent)
    @sheet3[15, 3] = data.newsmarket_bounce_rate
     @sheet3.row(16).set_format(3, percent)
    @sheet3[16, 3] = data.pansci_bounce_rate
     @sheet3.row(17).set_format(3, percent)
    @sheet3[17, 3] = data.einfo_bounce_rate
     @sheet3.row(18).set_format(3, percent)
    @sheet3[18, 3] = data.npost_bounce_rate
     @sheet3.row(19).set_format(3, percent)
    @sheet3[19, 3] = data.womany_bounce_rate

    @sheet3[14, 4] = data.sein_pageview
    @sheet3[15, 4] = data.newsmarket_pageview
    @sheet3[16, 4] = data.pansci_pageview
    @sheet3[17, 4] = data.einfo_pageview
    @sheet3[18, 4] = data.npost_pageview
    @sheet3[19, 4] = data.womany_pageview

    @sheet3[14, 5] = "#{data.sein_on_site / 60}分#{data.sein_on_site % 60}秒"
    @sheet3[15, 5] = "#{data.newsmarket_on_site / 60}分#{data.newsmarket_on_site % 60}秒"
    @sheet3[16, 5] = "#{data.pansci_on_site / 60}分#{data.pansci_on_site % 60}秒"
    @sheet3[17, 5] = "#{data.einfo_on_site / 60}分#{data.einfo_on_site % 60}秒"
    @sheet3[18, 5] = "#{data.npost_on_site / 60}分#{data.npost_on_site % 60}秒"
    @sheet3[19, 5] = "#{data.womany_on_site / 60}分#{data.womany_on_site % 60}秒"
  end

  def export
    book.write xls_report
    xls_report.string
  end

end