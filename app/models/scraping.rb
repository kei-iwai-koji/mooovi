class Scraping
  def self.movie_urls
    agent = Mechanize.new   #Mechanizeクラスのインスタンスを生成する
    links = []   #linksという配列を作る

    next_url = ""

    # ここから↓
    while true do
      current_page = agent.get("http://review-movie.herokuapp.com/" + next_url)   #一覧ページのURL
      elements = current_page.search('.entry-title a')   #そのページにある全ての映画の個別URLのタグを取得
      elements.each do |ele|   #個別URLのタグからhref要素を取り出し、links配列に格納する
        links << ele.get_attribute('href')
      end

      next_link = current_page.at('.pagination .next a')   #次Pのリンクをタグごと獲得
      break unless next_link   #next_linkが空ならbreak（抜ける）
      next_url = next_link.get_attribute('href')   #タグからURL末尾を取り出してnext_urlに入れる
    end
    #↑ここまで繰り返す

      links.each do |link|   #get_productを実行する際にリンクを引数として渡す
        get_product('http://review-movie.herokuapp.com/' + link)   #個別PのURL
      end
  end

  def self.get_product(link)   #引数として渡された個別ページのリンクURLを使って「作品名」と「作品画像のURL」をスクレイピングし、それらをproductsテーブルに保存する処理
    agent = Mechanize.new   #インスタンスを生成する
    page = agent.get(link)   #映画の個別ページのURLを取得
    title = page.at('.entry-title').inner_text if page.at('.entry-title')   #映画のタイトルを取得

    image_url = page.at('.entry-content img')[:src] if page.at('.entry-content img')   #image_urlがあるsrc要素のみを取り出す
    director = page.at('.review_details .director span').inner_text if page.at('.review_details .director span')
    detail = page.at('.entry-content p').inner_text if page.at('.entry-content p')
    open_date = page.at('.review_details .date span').inner_text if page.at('.review_details .date span')

    product = Product.where(title: title).first_or_initialize   #同じタイトルがあればそれを返し無ければ作る
    product.image_url = image_url   #productのimage_urlカラムにimage_urlを入れる
    product.director = director
    product.detail = detail
    product.open_date = open_date
    product.save   #保存
  end
end

