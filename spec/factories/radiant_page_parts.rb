FactoryBot.define do
  factory :page_part, class: 'Radiant::PagePart' do
    name { "body" }
    content { "Lorem ipsum dolor sit amet" }
    filter_id { "Text" }
    page_id { nil }
  end
end
