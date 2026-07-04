-- Migration script generated from Excel Data

-- 1. Ensure required constraints are dropped so we can insert partial rows
ALTER TABLE public.registrations ALTER COLUMN full_name DROP NOT NULL;
ALTER TABLE public.registrations ALTER COLUMN email DROP NOT NULL;

-- 2. Clear out any previously seeded manual records to avoid duplicates
DELETE FROM public.registrations WHERE user_id IS NULL AND participant_type != 'attendee';

-- ===================== ImplementorsPartners =====================
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES (NULL, NULL, NULL, NULL, 'implementor', NULL, NULL, 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES (NULL, NULL, NULL, NULL, 'implementor', NULL, NULL, 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES (NULL, NULL, NULL, NULL, 'implementor', NULL, NULL, 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES (NULL, NULL, NULL, NULL, 'implementor', NULL, NULL, 'pending');

-- ===================== Stakeholders =====================
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Gregory Kituku', 'kzavuvu@gmail.com', '0722 965 662', 'Ministry of Mining (National)', 'stakeholder', 'Director of Licensing, Compliance, and Enforcement', 'Government', 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Job Onyancha', NULL, '0727985093', 'Ministry of Mines (Turkana)', 'stakeholder', 'County Mining Officer', 'Government', 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Hillary Koech', 'koechhillary23@outlook.com', '710468672', 'Turkana County', 'stakeholder', 'Representing the SDM', NULL, 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Olima Justus', NULL, '0727 423 864', 'Migori County Government - Department of Environment, natural resources and disaster management', 'stakeholder', 'Director', NULL, 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Sophie Kutiti', 'chairmrb@gmail.com', '0721704014', 'Mining Rights Board', 'stakeholder', '0721704014', NULL, 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Hon. Joseph Lagat/Eng Joseph Kitilit', 'nmoinket@namico.go.ke', NULL, 'NAMICO', 'stakeholder', 'CEO', 'Government', 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Hillary Koech', 'koechhillary23@outlook.com', NULL, 'Turkana County', 'stakeholder', 'Representing the SDM', NULL, 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Chinese Embassy', NULL, NULL, 'Chinese Embassy', 'stakeholder', NULL, NULL, 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Christopher Ellinger', 'christopher.ellinger@dfat.gov.au, angeli.damodaran@dfat.gov.au', NULL, 'Australian High Commission', 'stakeholder', 'Deputy High Commissioner', NULL, 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Charles Komen', 'miningcommittee@kenyachamber.or.ke, komenc2000@gmail.com', NULL, 'KNCCI - Mining Committee', 'stakeholder', 'Chairman', NULL, 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Canadian Embassy', NULL, NULL, 'Canadian Embassy', 'stakeholder', NULL, NULL, 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('British High Commission', NULL, NULL, 'British High Commission', 'stakeholder', NULL, NULL, 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('France Embassy in Kenya', NULL, NULL, 'France Embassy in Kenya', 'stakeholder', NULL, NULL, 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('The European Union', NULL, NULL, 'The European Union', 'stakeholder', NULL, NULL, 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('US Embassy', NULL, NULL, 'US Embassy', 'stakeholder', NULL, NULL, 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Ben', 'mgropsmigori@kcb.co.ke', NULL, 'KCB', 'stakeholder', NULL, 'Financial Institution', 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Ben Kariuki Githaeh', 'kariuki.githae@equitybank.co.ke', '0763248619/0722248619', 'Equity Bank', 'stakeholder', 'Regional Manager-Asset finance', 'Financial Institution', 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Nicodemus Atela', 'nicodemus.atela@equitybank.co.ke', NULL, NULL, 'stakeholder', NULL, 'Financial Institution', 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Simon', 'info@smep.co.ke', NULL, 'SMEP', 'stakeholder', NULL, 'Financial Institution', 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Sidian Bank', NULL, NULL, 'Sidian Bank', 'stakeholder', NULL, 'Financial Institution', 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Mary Njeri', 'mary.njeri@ncbagroup.com', NULL, 'NCBA', 'stakeholder', NULL, 'Financial Institution', 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Lucy Kireti', 'lucy.kireti@ncbagroup.com', '0720288444/0707132013', 'NCBA', 'stakeholder', 'Regional Manager(Nairobi) -Assset finance', 'Financial Institution', 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Kennedy Kang''ethe Njuguna', 'kennnedy.kangethe@ncbagroup.com', '0711056040/0722311519', 'NCBA', 'stakeholder', 'Business Development Manager', 'Financial Institution', 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Hophin Lungwe', 'hophin.lungwe@ncbagroup.com', NULL, 'NCBA', 'stakeholder', 'Migori Branch', 'Financial Institution', 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Zakayos Nambafu', 'zakayos.nambafu@ncbagroup.com', NULL, 'NCBA', 'stakeholder', 'Migori Brance', 'Financial Institution', 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Central Bank of Kenya', NULL, NULL, 'Central Bank of Kenya', 'stakeholder', NULL, NULL, 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('David Akumu', 'dakumu@co-opbank.co.ke', '0711049788/0723237481', 'Cooperative Bank of Kenya', 'stakeholder', 'Head Asset Finance & leasing', 'Financial Institution', 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Katherine Gachanja', 'kgachanja@dtbafrica.com', NULL, 'DTB Africa', 'stakeholder', NULL, 'Financial Institution', 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Charles Nyoro', 'cnyoro@dtbafrica.com', NULL, NULL, 'stakeholder', NULL, 'Financial Institution', 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Patrick Wainaina', 'patrick.wainaina@absa.africa', NULL, 'ABSA Kenya', 'stakeholder', NULL, 'Financial Institution', 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Stephen Awuor', 'stephen.awuor@absa.africa', NULL, NULL, 'stakeholder', NULL, 'Financial Institution', 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('OtienoJack Odhiambo', 'otienojack.odhiambo@absa.africa', NULL, NULL, 'stakeholder', NULL, 'Financial Institution', 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('KWFT Bank', 'sokore@kwftbank.com', NULL, 'KWFT Bank', 'stakeholder', NULL, 'Financial Institution', 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Nabil Adamjee', NULL, '0716244777', 'YeHu Microfinance', 'stakeholder', NULL, 'Financial Institution', 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Philippa Hutchinson', 'Philippa.Hutchinson@shantagoldltd.com', '0724205568', 'Shanta Gold', 'stakeholder', NULL, NULL, 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Washington Ayiemba', 'washington.ayiemba@undp.org', '0733803060', 'planet Gold', 'stakeholder', 'UNDP representative in Kenya', 'CSO/NGO Extractive', 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Jeremy Froome', 'jpf@karebemine.com', '0717717771  /  0733777463', 'Karebe Gold Mining Limited', 'stakeholder', NULL, NULL, 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Jeremy Froome', 'jpf@karebemine.com / hr@karebemine.com', '0717717771 / 733777463', 'Karebe Gold Mine', 'stakeholder', NULL, NULL, 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Edgar Odari', 'e.odari@econews-africa.org', NULL, 'Haki Madini / NCCK', 'stakeholder', 'Co-chairperson of the coalition', 'CSO/NGO Extractive', 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Michelle Mwambela', 'ceo@aweik.or.ke', '0715788869', 'AWEIK (Association for Women in Extractives and Energy in Kenya)', 'stakeholder', 'CEO', 'CSO/NGO Extractive', 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Dan Odida', 'odidad72@gmail.com', '0722 118 843', 'Migori County Miners Association', 'stakeholder', 'Secretary', NULL, 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Turkana County ASM committee', NULL, NULL, 'Turkana County ASM committee', 'stakeholder', 'Chairman', NULL, 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('NEMA Turkana', NULL, NULL, 'NEMA Turkana', 'stakeholder', NULL, NULL, 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Dan Odida', 'odidad72@gmail.com, info@asmak.com', NULL, 'ASMAK', 'stakeholder', 'Chairman', NULL, 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Jeremy Olemoonka', 'olemoonka@gmail.com', NULL, NULL, 'stakeholder', 'General Secretary', NULL, 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Kaputir Resource Management Organization(KARMO)', 'karmoturkana@gmail.com', '727106990', 'Kaputir Resource Management Organization(KARMO)', 'stakeholder', NULL, NULL, 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Geol. Joseph Ng''ang''a Kuria', 'info@gsk.or.ke', NULL, 'Geological Society of Kenya', 'stakeholder', 'Chairman', NULL, 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Griffins Ochieng', 'ogriffins@gmail.com', '0726931318', 'CEJAD', 'stakeholder', 'Director', NULL, 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Joseph Komu', 'info@mesk.co.ke, Joseph.komu87@gmail.com', NULL, 'MESK', 'stakeholder', 'Chairman', NULL, 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Esther Njung''e', 'enjunge@pactworld.org', '0702203864', 'Pact  World', 'stakeholder', 'Kenyan Representative', 'CSO/NGO Extractive', 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Daniel', NULL, '711943832', 'Catholic Diocese-Lodwar', 'stakeholder', NULL, NULL, 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Harrigan Mukhongo', 'harrigan.mukhongo@gmail.com', NULL, 'USAID Connection', 'stakeholder', 'Former Head of USAID', 'Financial Institution', 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Robert Khisa', 'robert@prdrigs.co.ke', '727395165', 'PRD Rigs Kenya Ltd', 'stakeholder', NULL, NULL, 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Nowata Great Lakes', NULL, NULL, 'Nowata Great Lakes', 'stakeholder', NULL, NULL, 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Nile Machineries', NULL, NULL, 'Nile Machineries', 'stakeholder', NULL, NULL, 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Francis Mghola', 'maghomining@gmail.com', NULL, 'Magho Ltd', 'stakeholder', 'Director', 'Equipment Providers', 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Griffins Ochieng', 'ogriffins@gmail.com', NULL, NULL, 'stakeholder', NULL, NULL, 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Vishal Khagram', 'vishal@samilamining.com', '0733617350', 'Samila Mining', 'stakeholder', NULL, NULL, 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Moses Karanja/Kishor Varsani', 'varsaniKD@aggregatesafrica.com,
daniel@aggregatesafrica.com', '0722788886', 'Karsan Ramji &Sons Ltd', 'stakeholder', 'Director', 'Equipment Providers', 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Happinness', 'info@neschmintech.tech', NULL, 'Neschmintech Laboratories Tanzania.', 'stakeholder', NULL, 'Equipment Providers', 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('George', 'georgew@liugong.com', '0746860074', 'Liungong Machinery Ltd', 'stakeholder', 'Sales Representative', 'Equipment Providers', 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Diana', 'diana@liugong.com', '0723161330', NULL, 'stakeholder', 'Sales Representative', 'Equipment Providers', 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Jewelers Association of Kenya', NULL, NULL, 'Jewelers Association of Kenya', 'stakeholder', NULL, NULL, 'pending');

-- ===================== Call List =====================
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('Guest of Honor', NULL, NULL, NULL, 'call_list', 'Guest of Honor', NULL, 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('[[', NULL, NULL, NULL, 'call_list', '[[', NULL, 'pending');

-- ===================== Volunteers =====================
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('MESK', NULL, NULL, 'MESK', 'volunteer', NULL, NULL, 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('MESK', NULL, NULL, 'MESK', 'volunteer', NULL, NULL, 'pending');
INSERT INTO public.registrations (full_name, email, phone, organization, participant_type, job_title, industry_affiliate, status)
VALUES ('MESK', NULL, NULL, 'MESK', 'volunteer', NULL, NULL, 'pending');

