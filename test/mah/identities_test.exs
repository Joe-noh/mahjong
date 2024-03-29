defmodule Mah.IdentitiesTest do
  use Mah.DataCase, async: true

  alias Mah.Identities

  describe "get_user!/1" do
    setup do
      {:ok, user} = Fixtures.create(:user)
      %{user: user}
    end

    test "returns a user", %{user: %{id: id, name: name}} do
      assert %{name: ^name} = Identities.get_user!(id)
    end

    test "raise if user does not exist" do
      assert_raise Ecto.NoResultsError, fn -> Identities.get_user!("fa1b53c8-4c70-4d30-bee6-560fb8891ef5") end
    end
  end

  describe "create_user/1" do
    test "with valid data creates a user" do
      assert {:ok, user} = Identities.create_user(%{"name" => "john"})
      assert user.name == "john"
    end

    test "with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Identities.create_user(%{})
    end

    test "cannot create the same name users" do
      assert {:ok, user} = Identities.create_user(%{"name" => "john"})
      assert {:error, changeset} = Identities.create_user(%{"name" => "john"})

      assert changeset.errors |> Keyword.has_key?(:name)
    end
  end

  @firebase_payload %{
    "name" => "風化させないbot",
    "picture" => "https =>//pbs.twimg.com/profile_images/986579596693794816/AVrTgv1h_normal.jpg",
    "iss" => "https =>//securetoken.google.com/mah-development",
    "aud" => "mah-development",
    "auth_time" => 1_565_347_634,
    "user_id" => "HDsoCmiNUrQzC6MxtpaljELDFQv1",
    "sub" => "HDsoCmiNUrQzC6MxtpaljELDFQv1",
    "iat" => 1_565_347_634,
    "exp" => 1_565_351_234,
    "firebase" => %{
      "identities" => %{
        "twitter.com" => ["275472173"]
      },
      "sign_in_provider" => "twitter.com"
    }
  }

  describe "signup_with_firebase_payload/1" do
    test "create user and social_account" do
      {:ok, %{user: user, social_account: social_account}} = Identities.signup_with_firebase_payload(@firebase_payload)

      assert user.name == "風化させないbot"
      assert social_account.uid == "275472173"
      assert social_account.provider == "twitter.com"
    end

    test "returns existing user if signed up twice" do
      {:ok, %{user: u1, social_account: s1}} = Identities.signup_with_firebase_payload(@firebase_payload)

      assert Repo.aggregate(Identities.User, :count, :id) == 1
      assert Repo.aggregate(Identities.SocialAccount, :count, :id) == 1

      {:ok, %{user: u2, social_account: s2}} = Identities.signup_with_firebase_payload(@firebase_payload)

      assert Repo.aggregate(Identities.User, :count, :id) == 1
      assert Repo.aggregate(Identities.SocialAccount, :count, :id) == 1
      assert u1.id == u2.id
      assert s1.id == s2.id
    end
  end
end
