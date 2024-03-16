require 'rails_helper'

RSpec.describe "Users", type: :system do
  let!(:user) { create(:user) }
  let(:admin_user){ create(:user, :admin) }
  let!(:other_user) { create(:user) } 

  describe "ユーザー一覧ページ" do
    context "管理者ユーザーの場合" do
      it "ぺージネーション、削除ボタンが表示されること" do
        create_list(:user, 31)
        sign_in user
        visit users_path
        expect(page).to have_css "div.pagination"
        User.paginate(page: 1).each do |u|
          expect(page).to have_link u.name, href: user_path(u)
          expect(page).to have_content "#{u.name} | 削除" unless u == admin_user
        end
      end
    end

    context "管理者ユーザー以外の場合" do
      it "ページネーション、自分のアカウントのみ削除ボタンが表示されること" do
        create_list(:user, 30)
        sign_in user
        visit users_path
        expect(page).to have css "div.pagination"
        User.paginate(page:1).each do |u|
          expect(page).to have_link u.name, href: user_path(u)
          if u == user
            expect(page).to have_content "#{u.name} | 削除"
          else
            expect(page).not_to have_content "#{u.name} | 削除"
          end
        end
      end
    end
  end

  describe "ユーザー登録ページ" do
    before do
      visit new_user_registration_path
    end

    context "ページレイアウト" do
      it "「ユーザー登録」の文字列が存在することを確認" do
        expect(page).to have_content 'ユーザー登録'
      end

      it "正しいタイトルが表示されることを確認" do
        expect(page).to have_title('ユーザー登録 - アニバポスト')
      end
    end

    context "ユーザー登録処理" do
      it "有効なユーザーでユーザー登録を行うとユーザー登録成功のフラッシュが表示されること" do
        fill_in "ユーザーネーム", with: "Example user"
        fill_in "メールアドレス", with: "user@example.com"
        fill_in "パスワード", with: "password"
        fill_in "パスワード（確認用）", with: "password"
        click_button "アカウント登録"
        expect(page).to have_content("アカウント登録が完了しました。")
      end
    
      it "無効なユーザーでユーザー登録を行うとユーザー登録失敗のフラッシュが表示されること" do
        fill_in "ユーザーネーム", with: ""
        fill_in "メールアドレス", with: "user@example.com"
        fill_in "パスワード", with: "password"
        fill_in "パスワード（確認用）", with: "pass"
        click_button "アカウント登録"
        expect(page).to have_content "ユーザー名を入力してください"
        expect(page).to have_content "パスワード(確認)とパスワードの入力が一致しません"
      end
    end
  end
  
  describe "プロフィールページ" do
    context "ページレイアウト" do
      before do
        sign_in user
        visit user_path(user)
        create_lists(:user, 10, child_post: 10)
      end
  
      it "「プロフィール」の文字列が存在することを確認" do
        expect(page).to have_content 'プロフィール'
      end
  
      it "正しいタイトルが表示されることを確認" do
        expect(page).to have_title('ユーザー詳細 - アニバポスト')
      end
  
      it "ユーザー情報が表示されることを確認" do
        expect(page).to have_content user.name
        expect(page).to have_content user.profile
        expect(page).to have_content user.email
      end

      it "子供の記念日投稿の数が記載されているか確認" do
        expect(page).to have_content "こども記念日(#{user.child_posts.count})"
      end

      it "子供記念日の情報が表示されているか確認" do
        child_post.take(5).each do |child_post|
          expect(page).to have_content child_post.content
        end
      end

      it "子供記念日投稿のページネーションが表示されているか確認"
        expect(page).to have_css "div.pagination"
      end 
    end

    context "ユーザーのフォロー/アンフォロー処理" , js:true do
      it "ユーザーのフォロー/アンフォロー処理ができること" do
        sign_in user
        visit user_path(user)
        expect(page).to have_button 'フォローする'
        click_button 'フォローする'
        expect(page).to have_button 'フォロー中'
        click_button 'フォロー中'
        expect(page).to have_button 'フォローする'
      end
    end
  end

  describe "プロフィール編集ページ" do
    context "アカウント削除", js:true do
      it "正しく削除できること" do
        click_link "アカウントを削除する" 
        page.driver.browser.switch_to.alert.accept
        expext(page).to have_content "自分のアカウントを削除しました"
      end
    end
  end
end
