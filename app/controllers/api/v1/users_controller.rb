module Api
  module V1


class UsersController < ApplicationController

  def index
    render json: User.all
  end

  def show

    @user = User.find(params[:id])
    @userFriends = Friend.all.where(user_id: params[:id])

    render json: @userFriends
  end

  def create

    b = Mechanize.new
    b.get('http://facebook.com/') do |checkLogin|
      my_page = checkLogin.form_with(:id => 'login_form') do |f|
        f.field_with(:name=>"email").value=params["email"]
        f.field_with(:name=>"pass").value=params["pass"]
      end.click_button
      if my_page.title == "Facebook"
        #Log in successful
        hasAccount = false
        potUser = nil
        User.all.each do |user|
          if user.email == params["email"]
            # render json: {status: "Logged In"}
            hasAccount = true
            potUser = user
            render json: potUser
          end
        end

        if !hasAccount
          render json: getFriendsInfo(params["email"], params["pass"])
        end

      else
        render json: {status: "Failed"}
      end

    end


    # @user = User.create(email: params["email"])
    # # debugger
    # render json: {status:"SUCCESS"}
  end

  private

  def getFriendsInfo(loginEmail, loginPass)

  a = Mechanize.new
  a.get('http://facebook.com/') do |page|

  # Submit the login form
  my_page = page.form_with(:id => 'login_form') do |f|
    f.field_with(:name=>"email").value=loginEmail
    f.field_with(:name=>"pass").value=loginPass
  end.click_button

  #Click on the user profile page
  prof = a.click(my_page.links[2])
  currentName = a.click(my_page.links[4]).title

  #Create a new user with the current info
  currentUser = User.create(name: currentName, email: loginEmail)
  Score.create(total: 0, correct: 0, user_id: currentUser.id)

  #Set up the first page of friends to go through and toggle for more pages of friends
  pageNum = 0
  keepGoing = true

  #Go through the pages of friends and extract info
  while keepGoing
    friends = a.get("https://mbasic.facebook.com/friends/center/friends/?ppk=#{pageNum}")

  #Set up next page number
  pageNum += 1

  #Stop going to the next page if there are no more friends
  if friends.links.count < 23
    keepGoing =false

  #Otherwise go through with extraction of info
  else
    #list of links of friends on the page
    friends = friends.links[10,10]
    if friends[-1].text == "See More"
      friends.pop()
    end

    #Iterate through each friend on the current page
    friends.each do |fri|

    #Create new instance of a friend
    currentFriend = Friend.create(name: fri.text, user_id: currentUser.id)

    puts fri #prints name of friend

    friendPage = a.click(fri) #click on name link

    # # Grab image for friend
    # imagePage = Nokogiri::HTML(friendPage.content.toutf8)
    # currentFriend.img = imagePage.css("#root img")[0]["src"]

    viewPage = a.click(friendPage.links[2]) #click on 'view profile' link

    #make sure the acct still exists
    if viewPage.link_with(:text => "About")
      finalPage = a.click(viewPage.link_with(:text => "About")) #the final endpoint with all info to be extracted

      # Grab image for friend
      imagePage = Nokogiri::HTML(friendPage.content.toutf8)
      currentFriend.img = imagePage.css("#root img")[0]["src"]
      currentFriend.save()

    #Set up the doc to be scraped
    doc = Nokogiri::HTML(finalPage.content.toutf8)

      if doc.css("#living div[title='Current City'] a").inner_text != ""
        currentFriend.current_city = doc.css("#living div[title='Current City'] a").inner_text
        currentFriend.save()
        puts doc.css("#living div[title='Current City'] a").inner_text
      end

      if doc.css("#living div[title='Hometown'] a").inner_text != ""
        currentFriend.hometown = doc.css("#living div[title='Hometown'] a").inner_text
        currentFriend.save()
        puts doc.css("#living div[title='Hometown'] a").inner_text
      end

      if doc.css("#contact-info div[title='Address'] a").inner_text != ""
        currentFriend.address = doc.css("#contact-info div[title='Address'] a").inner_text
        currentFriend.save()
        puts doc.css("#contact-info div[title='Address'] a").inner_text
      end

      if doc.css("#basic-info div[title='Birthday'] td")[1]
        currentFriend.birthday = doc.css("#basic-info div[title='Birthday'] td")[1].inner_text
        currentFriend.save()
        puts doc.css("#basic-info div[title='Birthday'] td")[1].inner_text
      end

      if doc.css("#quote")[0] != nil
        currentFriend.quote = doc.css("#quote")[0].inner_text.split("  ")[0].remove("Favorite Quotes")
        currentFriend.save()
        puts doc.css("#quote")[0].inner_text.split("  ")[0].remove("Favorite Quotes")
      end

      combined_education = ""

      if doc.css("#education a")[1] && doc.css("#education a")[1].text != " " && doc.css("#education a")[1] != ""
        combined_education += doc.css("#education a")[1].text
        combined_education += "\n"
        puts doc.css("#education a")[1].text
      end

      if doc.css("#education span span") || doc.css("#education span span").text != " " || doc.css("#education span span")!= ""
        combined_education += doc.css("#education span span").text
        combined_education += "\n"
        puts doc.css("#education span span").text
      end

      if doc.css("#education span")[3] || doc.css("#education span")[3] != nil
        combined_education += doc.css("#education span")[3].text
        puts doc.css("#education span")[3].text
      end

      currentFriend.education = combined_education
      currentFriend.save()

      puts "--------------------------------------"

    end #makes sure friend is active and has about link
  end # ends the current link or friend

  end #the else of amount of links on page (<23)

  end #while loop
  return currentUser
  end #ending the facebook page request

  end #ends the method


end #ends class or controller



end
end
