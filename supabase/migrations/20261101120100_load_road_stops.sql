-- Job 20-a1-road: the 6 parts and 36 stops of the A1 road.
-- Made by scripts/generate/road_sql.py from docs/curriculum-a1.md, content/written/part-1.md to
-- part-6.md and content/road/stops.json. Do not edit by hand: change those files and run the
-- script again. A test fails when this file differs from the script's output.
-- Running it a second time changes nothing. Later legs of the road add their own migration.

insert into public.road_parts (number, title_en) values
  (1, 'First words'),
  (2, 'Daily life'),
  (3, 'Services'),
  (4, 'Work and people'),
  (5, 'Finnish life'),
  (6, 'Getting things done')
on conflict (number) do nothing;

insert into public.road_stops (number, slug, part_number, name_en, can_do_en, planned_dialogues) values
  (1, 'meeting-people', 1, 'Meeting people', 'say who I am and where I''m from, and ask the same.', 3),
  (2, 'ordering-coffee', 1, 'At the café', 'order something, ask the price, and say thanks.', 3),
  (3, 'grocery-store', 1, 'At the grocery store', 'ask where something is and follow simple directions.', 3),
  (4, 'numbers-prices-and-paying', 1, 'Numbers, prices and paying', 'ask what something costs and pay by card or cash.', 3),
  (5, 'getting-around-by-bus-and-tram', 1, 'Getting around by bus and tram', 'ask which bus or tram goes where and buy a ticket.', 3),
  (6, 'small-talk-weather-and-the-weekend', 1, 'Small talk: weather and the weekend', 'talk about the weather and say what I did.', 3),
  (7, 'asking-for-help', 2, 'Asking for help', 'say I don''t understand and ask someone to repeat or slow down.', 3),
  (8, 'making-a-plan', 2, 'Making a plan', 'suggest a time, accept, and say no politely.', 3),
  (9, 'times-and-appointments', 2, 'Times and appointments', 'tell the time and book an appointment.', 3),
  (10, 'at-the-pharmacy', 2, 'At the pharmacy', 'say what is wrong and ask for something for it.', 3),
  (11, 'home-and-neighbours', 2, 'Home and neighbours', 'say where I live and talk with my neighbours.', 3),
  (12, 'shopping-for-clothes', 2, 'Shopping for clothes', 'ask for a size and colour and try something on.', 3),
  (13, 'at-the-health-centre', 3, 'At the health centre', 'book a visit and describe where it hurts.', 3),
  (14, 'phone-calls-and-messages', 3, 'Phone calls and messages', 'start and end a phone call and leave a message.', 3),
  (15, 'the-bank-and-kela', 3, 'The bank and Kela', 'ask about a form and say what I need.', 3),
  (16, 'collecting-a-parcel', 3, 'Collecting a parcel', 'pick up a parcel and spell my name.', 3),
  (17, 'lunch-out', 3, 'Lunch out', 'read a lunch menu and order politely.', 3),
  (18, 'housing-and-repairs', 3, 'Housing and repairs', 'report that something is broken.', 3),
  (19, 'first-day-at-work', 4, 'First day at work', 'introduce myself at work and ask where things are.', 3),
  (20, 'talking-about-family', 4, 'Talking about family', 'say who is in my family.', 3),
  (21, 'school-and-daycare', 4, 'School and daycare', 'talk with the daycare and school about my children.', 3),
  (22, 'free-time-and-hobbies', 4, 'Free time and hobbies', 'say what I like doing.', 3),
  (23, 'cooking-at-home', 4, 'Cooking at home', 'make a shopping list and follow a simple recipe.', 3),
  (24, 'how-you-feel', 4, 'How you feel', 'say how I feel and ask how someone is.', 3),
  (25, 'coffee-break-and-sauna', 5, 'Coffee break and sauna', 'join a coffee break and accept a sauna invitation.', 3),
  (26, 'holidays', 5, 'Holidays', 'talk about Midsummer and Christmas and give dates.', 3),
  (27, 'seasons-and-the-dark-winter', 5, 'Seasons and the dark winter', 'talk about the seasons and the weather over a year.', 3),
  (28, 'at-the-library', 5, 'At the library', 'get a library card and borrow a book.', 3),
  (29, 'out-in-nature', 5, 'Out in nature', 'plan a walk in the forest and talk about berries.', 3),
  (30, 'invitations-and-celebrations', 5, 'Invitations and celebrations', 'accept an invitation and thank the host.', 3),
  (31, 'directions-in-the-city', 6, 'Directions in the city', 'ask the way and follow left, right and straight on.', 3),
  (32, 'problems-and-returns', 6, 'Problems and returns', 'return something and explain what is wrong.', 3),
  (33, 'my-past', 6, 'My past', 'say where I lived and worked before.', 3),
  (34, 'my-plans', 6, 'My plans', 'talk about tomorrow, next week and next year.', 3),
  (35, 'my-work-and-skills', 6, 'My work and skills', 'say what I do and what I can do.', 3),
  (36, 'a-day-in-my-life', 6, 'A day in my life', 'tell someone about my day and my life here, from start to finish.', 3)
on conflict (number) do nothing;
