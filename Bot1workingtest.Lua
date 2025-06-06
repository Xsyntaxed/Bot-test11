-- Roblox multilingual chat translator bot with language selection
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local SayMessageRequest = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") and ReplicatedStorage.DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")

local selectedLanguage = nil
local translationEnabled = false
local lastMessage = ""
local cooldown = 2
local lastSendTime = 0

local vowels = {
    Tagalog = "aeiou",
    German = "aeiouäöü",
    Chinese = "aeiou",
    Russian = "аеёиоуыэюя",
    Japanese = "あいうえお",
    Thai = "อะอิอุเอโอ",
    Vietnamese = "aeiouâăêôơư"
}

local alphabet = {
    Tagalog = "abcdefghijklmnopqrstuvwxyz",
    German = "abcdefghijklmnopqrstuvwxyzäöüß",
    Chinese = "abcdefghijklmnopqrstuvwxyz",
    Russian = "абвгдеёжзийклмнопрстуфхцчшщъыьэюя",
    Japanese = "あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをん",
    Thai = "กขฃคฅฆงจฉชซฌญฎฏฐฑฒณดตถทธนบปผฝพฟภมยรฤลฦวศษสหฬอฮ",
    Vietnamese = "abcdefghijklmnopqrstuvwxyzăâđêôơư"
}

local dictionaries = {
    Tagalog = {
        hello = "kamusta", hi = "hi", bye = "paalam", yes = "oo", no = "hindi",
        thank = "salamat", you = "ikaw", i = "ako", we = "kami", they = "sila",
        he = "siya", she = "siya", it = "ito", good = "mabuti", bad = "masama",
        morning = "umaga", night = "gabi", day = "araw", water = "tubig", food = "pagkain",
        house = "bahay", love = "pag-ibig", happy = "masaya", sad = "malungkot", come = "halika",
        go = "umalis", see = "tingnan", want = "gusto", know = "alam", help = "tulong",
        friend = "kaibigan", family = "pamilya", work = "trabaho", school = "paaralan", money = "pera",
        car = "kotse", run = "tumakbo", walk = "lakad", big = "malaki", small = "maliit",
        new = "bago", old = "luma", please = "pakiusap", sorry = "pasensya", what = "ano",
        who = "sino"
    },
    German = {
        hello = "hallo", hi = "hi", bye = "tschüss", yes = "ja", no = "nein",
        thank = "danke", you = "du", i = "ich", we = "wir", they = "sie",
        he = "er", she = "sie", it = "es", good = "gut", bad = "schlecht",
        morning = "morgen", night = "nacht", day = "tag", water = "wasser", food = "essen",
        house = "haus", love = "liebe", happy = "glücklich", sad = "traurig", come = "kommen",
        go = "gehen", see = "sehen", want = "wollen", know = "wissen", help = "hilfe",
        friend = "freund", family = "familie", work = "arbeit", school = "schule", money = "geld",
        car = "auto", run = "laufen", walk = "gehen", big = "groß", small = "klein",
        new = "neu", old = "alt", please = "bitte", sorry = "entschuldigung", what = "was",
        who = "wer"
    }, 

Chinese = {
        hello = "你好", hi = "嗨", bye = "再见", yes = "是", no = "不",
        thank = "谢谢", you = "你", i = "我", we = "我们", they = "他们",
        he = "他", she = "她", it = "它", good = "好", bad = "坏",
        morning = "早上", night = "晚上", day = "天", water = "水", food = "食物",
        house = "房子", love = "爱", happy = "高兴", sad = "难过", come = "来",
        go = "去", see = "看", want = "想要", know = "知道", help = "帮助",
        friend = "朋友", family = "家人", work = "工作", school = "学校", money = "钱",
        car = "车", run = "跑", walk = "走", big = "大", small = "小",
        new = "新", old = "旧", please = "请", sorry = "对不起", what = "什么",
        who = "谁"
    },
    Russian = {
        hello = "привет", hi = "привет", bye = "пока", yes = "да", no = "нет",
        thank = "спасибо", you = "ты", i = "я", we = "мы", they = "они",
        he = "он", she = "она", it = "оно", good = "хорошо", bad = "плохо",
        morning = "утро", night = "ночь", day = "день", water = "вода", food = "еда",
        house = "дом", love = "любовь", happy = "счастливый", sad = "грустный", come = "приходить",
        go = "идти", see = "видеть", want = "хотеть", know = "знать", help = "помощь",
        friend = "друг", family = "семья", work = "работа", school = "школа", money = "деньги",
        car = "машина", run = "бежать", walk = "ходить", big = "большой", small = "маленький",
        new = "новый", old = "старый", please = "пожалуйста", sorry = "извините", what = "что",
        who = "кто"
    }, 

Japanese = {
        hello = "こんにちは", hi = "やあ", bye = "さようなら", yes = "はい", no = "いいえ",
        thank = "ありがとう", you = "あなた", i = "私", we = "私たち", they = "彼ら",
        he = "彼", she = "彼女", it = "それ", good = "良い", bad = "悪い",
        morning = "朝", night = "夜", day = "日", water = "水", food = "食べ物",
        house = "家", love = "愛", happy = "幸せ", sad = "悲しい", come = "来る",
        go = "行く", see = "見る", want = "欲しい", know = "知る", help = "助ける",
        friend = "友達", family = "家族", work = "仕事", school = "学校", money = "お金",
        car = "車", run = "走る", walk = "歩く", big = "大きい", small = "小さい",
        new = "新しい", old = "古い", please = "お願いします", sorry = "ごめんなさい", what = "何",
        who = "誰"
    },
    Thai = {
        hello = "สวัสดี", hi = "หวัดดี", bye = "ลาก่อน", yes = "ใช่", no = "ไม่",
        thank = "ขอบคุณ", you = "คุณ", i = "ฉัน", we = "เรา", they = "พวกเขา",
        he = "เขา", she = "เธอ", it = "มัน", good = "ดี", bad = "ไม่ดี",
        morning = "เช้า", night = "คืน", day = "วัน", water = "น้ำ", food = "อาหาร",
        house = "บ้าน", love = "รัก", happy = "มีความสุข", sad = "เศร้า", come = "มา",
        go = "ไป", see = "เห็น", want = "ต้องการ", know = "รู้", help = "ช่วย",
        friend = "เพื่อน", family = "ครอบครัว", work = "งาน", school = "โรงเรียน", money = "เงิน",
        car = "รถ", run = "วิ่ง", walk = "เดิน", big = "ใหญ่", small = "เล็ก",
        new = "ใหม่", old = "เก่า", please = "กรุณา", sorry = "ขอโทษ", what = "อะไร",
        who = "ใคร"
    }, 

Vietnamese = {
        hello = "xin chào", hi = "chào", bye = "tạm biệt", yes = "vâng", no = "không",
        thank = "cảm ơn", you = "bạn", i = "tôi", we = "chúng tôi", they = "họ",
        he = "anh ấy", she = "cô ấy", it = "nó", good = "tốt", bad = "xấu",
        morning = "buổi sáng", night = "buổi tối", day = "ngày", water = "nước", food = "thức ăn",
        house = "nhà", love = "yêu", happy = "vui", sad = "buồn", come = "đến",
        go = "đi", see = "thấy", want = "muốn", know = "biết", help = "giúp",
        friend = "bạn bè", family = "gia đình", work = "công việc", school = "trường học", money = "tiền",
        car = "xe hơi", run = "chạy", walk = "đi bộ", big = "to", small = "nhỏ",
        new = "mới", old = "cũ", please = "làm ơn", sorry = "xin lỗi", what = "gì",
        who = "ai"
    }
}

local function notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 3
        })
    end)
end

local function translateWord(word)
    if not selectedLanguage then return word end
    local dict = dictionaries[selectedLanguage]
    if not dict then return word end
    local lowerWord = word:lower()
    if dict[lowerWord] then
        return dict[lowerWord]
    else
        return word
    end
end

local function translateText(text)
    if not selectedLanguage then return text end
    local words = {}
    for word in text:gmatch("%S+") do
        table.insert(words, translateWord(word))
    end
    return table.concat(words, " ")
end

-- Show language picker ONCE
local languageNotified = false
task.delay(1, function()
    if not languageNotified then
        notify("Language Picker", "Pick your language:\n1 = Tagalog\n2 = German\n3 = Chinese\n4 = Russian\n5 = Japanese\n6 = Thai\n7 = Vietnamese")
        languageNotified = true
    end
end)

local languageNotified = false

task.delay(1, function()
    if not languageNotified then
        notify("Language Picker", "Pick your language:\n1 = Tagalog\n2 = German\n3 = Chinese")
        task.delay(2, function()
            notify("Language Picker", "Pick your language:\n4 = Russian\n5 = Japanese\n6 = Thai\n7 = Vietnamese")
        end)
        languageNotified = true
    end
end)

    if tick() - lastSendTime < cooldown then return end
    lastSendTime = tick()

    local translated = translateText(text)
    if translated ~= text then
        if SayMessageRequest then
            SayMessageRequest:FireServer(translated, "All")
        else
            local channel = TextChatService:FindFirstChild("TextChannels") and TextChatService.TextChannels:FindFirstChild("RBXGeneral")
            if channel then
                channel:SendAsync(translated)
            end
        end
    end
end

if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
    TextChatService.MessageReceived:Connect(function(msg)
        if msg.TextSource and msg.TextSource.UserId == player.UserId then
            if msg.Text ~= lastMessage then
                lastMessage = msg.Text
                handleMessage(msg.Text)
            end
        end
    end)
else
    local function onChatted(msg)
        if msg ~= lastMessage then
            lastMessage = msg
            handleMessage(msg)
        end
    end
    player.Chatted:Connect(onChatted)
end

