//
//  TestData.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 2/12/24.
//

import Foundation

struct Goal {
    let title: String
    let statusImageName: String
    let viewerImageName: String
    
    init(title: String, statusImageName: String, viewerImageName: String) {
        self.title = title
        self.statusImageName = statusImageName
        self.viewerImageName = viewerImageName
    }
}



struct Constants {
    static let restrictedWords = [
        "Arse", "Ass", "Asshole", "Homosexual", "Homophobic", "Racist", "Gay", "Lgbt", "Jew", "Jewish", "Anti-semitic",
        "Chink", "Muslims", "Muslim", "Isis", "Islamophobe", "homophobe", "Bombing", "Sexyhot", "Bastard", "Bitch",
        "Fucker", "Cunt", "Damn", "Fuck", "Goddamn", "Shit", "Motherfucker", "Nigga", "Nigger", "Prick", "Shitass",
        "Son of a bitch", "Whore", "Thot", "Slut", "Faggot", "Dick", "Pussy", "Penis", "Vagina", "Negro", "Coon",
        "Bitched", "Sexist", "Freaking", "Cock", "Sucker", "Lick", "Licker", "Rape", "Molest", "Anal", "Buttrape",
        "Coont", "Cancer", "Sex", "Retard", "Fuckface", "Dumbass", "5h1t", "5hit", "A_s_s", "a2m", "a55", "adult",
        "amateur", "anal", "anal impaler†††", "anal leakage†††", "anilingus", "anus", "ar5e", "arrse", "arse",
        "arsehole", "ass fuck†††", "asses", "assfucker", "ass-fucker", "assfukka", "asshole", "asshole", "assholes",
        "assmucus†††", "assmunch", "asswhole", "autoerotic", "b!tch", "b00bs", "b17ch", "b1tch", "ballbag", "ballsack",
        "bang (one's) box†††", "bangbros", "bareback", "bastard", "beastial", "beastiality", "beef curtain†††",
        "bellend", "bestial", "bestiality", "bi+ch", "biatch", "bimbos", "birdlock", "bitch", "bitch tit†††", "bitcher",
        "bitchers", "bitches", "bitchin", "bitching", "bloody", "blow job", "blow me†††", "blow mud†††", "blowjob",
        "blowjobs", "blue waffle†††", "blumpkin†††", "boiolas", "bollock", "bollok", "boner", "boob", "boobs", "booobs",
        "boooobs", "booooobs", "booooooobs", "breasts", "buceta", "bugger", "bum", "bunny fucker", "bust a load†††",
        "busty", "butt", "butt fuck†††", "butthole", "buttmuch", "buttplug", "c0ck", "c0cksucker", "carpet muncher",
        "carpetmuncher", "cawk", "chink", "choade†††", "chota bags†††", "cipa", "cl1t", "clit", "clit licker†††",
        "clitoris", "clits", "clitty litter†††", "clusterfuck", "cnut", "cock", "cock pocket†††", "cock snot†††",
        "cockface", "cockhead", "cockmunch", "cockmuncher", "cocks", "cocksuck", "cocksucked", "cocksucker", "cock-sucker",
        "cocksucking", "cocksucks", "cocksuka", "cocksukka", "cok", "cokmuncher", "coksucka", "coon", "cop some wood†††",
        "cornhole†††", "corp whore†††", "cox", "cum", "cum chugger†††", "cum dumpster†††", "cum freak†††", "cum guzzler†††",
        "cumdump†††", "cummer", "cumming", "cums", "cumshot", "cunilingus", "cunillingus", "cunnilingus", "cunt",
        "cunt hair†††", "cuntbag†††", "cuntlick", "cuntlicker", "cuntlicking", "cunts", "cuntsicle†††", "cunt-struck†††",
        "cut rope†††", "cyalis", "cyberfuc", "cyberfuck", "cyberfucked", "cyberfucker", "cyberfuckers", "cyberfucking",
        "d1ck", "damn", "dick", "dick hole†††", "dick shy†††", "dickhead", "dildo", "dildos", "dink", "dinks", "dirsa",
        "dirty Sanchez†††", "dlck", "dog-fucker", "doggie style", "doggiestyle", "doggin", "dogging", "donkeyribber",
        "doosh", "duche", "dyke", "eat a dick†††", "eat hair pie†††", "ejaculate", "ejaculated", "ejaculates", "ejaculating",
        "ejaculatings", "ejaculation", "ejakulate", "erotic", "f u c k", "f u c k e r", "f_u_c_k", "f4nny", "facial†††",
        "fag", "fagging", "faggitt", "faggot", "faggs", "fagot", "fagots", "fags", "fanny", "fannyflaps", "fannyfucker",
        "fanyy", "fatass", "fcuk", "fcuker", "fcuking", "feck", "fecker", "felching", "fellate", "fellatio", "fingerfuck",
        "fingerfucked", "fingerfucker", "fingerfuckers", "fingerfucking", "fingerfucks", "fist fuck†††", "fistfuck",
        "fistfucked", "fistfucker", "fistfuckers", "fistfucking", "fistfuckings", "fistfucks", "flange", "flog the log†††",
        "fook", "fooker", "fuck hole†††", "fuck puppet†††", "fuck trophy†††", "fuck yo mama†††", "fuck", "fucka", "fuck-ass†††",
        "fuck-bitch†††", "fucked", "fucker", "fuckers", "fuckhead", "fuckheads", "fuckin", "fucking", "fuckings",
        "fuckingshitmotherfucker", "fuckme", "fuckmeat†††", "fucks", "fucktoy†††", "fuckwhit", "fuckwit", "fudge packer",
        "fudgepacker", "fuk", "fuker", "fukker", "fukkin", "fuks", "fukwhit", "fukwit", "fux", "fux0r", "gangbang",
        "gangbang†††", "gang-bang†††", "gangbanged", "gangbangs", "gassy ass†††", "gaylord", "gaysex", "goatse", "god",
        "god damn", "god-dam", "goddamn", "goddamned", "god-damned", "ham flap†††", "hardcoresex", "hell", "heshe", "hoar",
        "hoare", "hoer", "homo", "homoerotic", "hore", "horniest", "horny", "hotsex", "how to kill", "how to murdep",
        "jackoff", "jack-off", "jap", "jerk", "jerk-off", "jism", "jiz", "jizm", "jizz", "kawk", "kinky Jesus†††", "knob",
        "knob end", "knobead", "knobed", "knobend", "knobend", "knobhead", "knobjocky", "knobjokey", "kock", "kondum", "kondums", "kum", "kummer", "kumming", "kums", "kunilingus", "l3i+ch", "l3itch",
        "labia", "lmfao", "lust", "lusting", "m0f0", "m0fo", "m45terbate", "ma5terb8", "ma5terbate", "masochist", "master-bate",
        "masterb8", "masterbat", "masterbat3", "masterbate", "master-bate", "master-bates", "masturbat", "masturbate", "mo-fo",
        "mof0", "mofo", "mothafuck", "mothafucka", "mothafuckas", "mothafuckaz", "mothafucked", "mothafucker", "mothafuckers",
        "mothafuckin", "mothafucking", "mothafuckings", "mothafucks", "mother fucker", "motherfuck", "motherfucked", "motherfucker",
        "motherfuckers", "motherfuckin", "motherfucking", "motherfuckings", "motherfuckka", "motherfucks", "muff", "mutha", "muthafecker",
        "muthafuckker", "muther", "mutherfucker", "n1gga", "n1gger", "nazi", "nigg3r", "nigg4h", "nigga", "niggah", "niggas", "niggaz",
        "nigger", "niggers", "nob", "nob jokey", "nobhead", "nobjocky", "nobjokey", "numbnuts", "nutsack", "orgasim", "orgasims",
        "orgasm", "orgasms", "p0rn", "pawn", "pecker", "penis", "penisfucker", "phonesex", "phuck", "phuk", "phuked", "phuking",
        "phukked", "phukking", "phuks", "phuq", "pigfucker", "pimpis", "piss", "pissed", "pisser", "pissers", "pisses", "pissflaps",
        "pissin", "pissing", "pissoff", "poop", "porn", "porno", "pornography", "pornos", "prick", "pricks", "pron", "pube", "pusse",
        "pussi", "pussies", "pussy", "pussys", "rectum", "retard", "rimjaw", "rimming", "s hit", "s.o.b.", "sadist", "schlong", "screwing",
        "scroat", "scrote", "scrotum", "semen", "sex", "sh!+", "sh!t", "sh1t", "shag", "shagger", "shaggin", "shagging", "shemale",
        "shi+", "shit", "shitdick", "shite", "shited", "shitey", "shitfuck", "shitfull", "shithead", "shiting", "shitings", "shits",
        "shitted", "shitter", "shitters", "shitting", "shittings", "shitty", "skank", "slut", "sluts", "smegma", "smut", "snatch",
        "son-of-a-bitch", "spac", "spunk", "s_h_i_t", "t1tt1e5", "t1tties", "teets", "teez", "testical", "testicle", "tit", "titfuck",
        "tits", "titt", "tittie5", "tittiefucker", "titties", "tittyfuck", "tittywank", "titwank", "tosser", "turd", "tw4t", "twat",
        "twathead", "twatty", "twunt", "twunter", "v14gra", "v1gra", "vagina", "viagra", "vulva", "w00se", "wang", "wank", "wanker",
        "wanky", "whoar", "whore", "willies", "willy", "xrated", "xxx", "sucker", "dumbass", "kys", "kill", "die", "cliff", "bridge", "shooting", "shoot", "bomb",
        "terrorist", "terrorism", "bombed", "trump", "maga", "conservative", "make america great again", "far right",
        "necrophilia", "mongoloid", "furfag", "cp", "pedo", "pedophile", "pedophilia", "child predator", "predatory",
        "depression", "cut myself", "i want to die", "fuck life", "redtube", "loli", "lolicon", "cub"
    ]
}
struct TestData {
    static let personalIndividualGoals: [Goal] = [
        Goal(title: "Developing here", statusImageName: "Green", viewerImageName: ""),
        Goal(title: "Developing here", statusImageName: "Yellow", viewerImageName: ""),
        Goal(title: "Eat out once a week", statusImageName: "Red", viewerImageName: ""),
        Goal(title: "workout twice a week", statusImageName: "Green", viewerImageName: ""),
        Goal(title: "No perking tickets", statusImageName: "Green", viewerImageName: ""),
        Goal(title: "Save $10k", statusImageName: "Green", viewerImageName: ""),
        Goal(title: "Practice spanish daily", statusImageName: "Green", viewerImageName: ""),
        Goal(title: "Call parents weekly", statusImageName: "Yellow", viewerImageName: ""),
        Goal(title: "Buy a house/ find a house", statusImageName: "Red", viewerImageName: ""),
        Goal(title: "Never miss a bill", statusImageName: "Green", viewerImageName: "")
    ]
    static let personalGroupGoals: [Goal] = [
        Goal(title: "Developing", statusImageName: "Green", viewerImageName: "crown"),
        Goal(title: "Developing", statusImageName: "Red", viewerImageName: "crown"),
        Goal(title: "Developing", statusImageName: "Green", viewerImageName: "crown")
    ]
    
    static let professionalIndividualGoals: [Goal] = [
        Goal(title: "Submit timesheet on time", statusImageName: "Green", viewerImageName: ""),
        Goal(title: "Use all vacation time", statusImageName: "Yellow", viewerImageName: ""),
        Goal(title: "No late days", statusImageName: "Red", viewerImageName: ""),
        Goal(title: "20 percent increase in productivity", statusImageName: "Green", viewerImageName: ""),
        Goal(title: "Lead 3 client meetings", statusImageName: "Green", viewerImageName: "")
    ]
    static let professionalGroupGoals: [Goal] = [
        Goal(title: "Developing", statusImageName: "Yellow", viewerImageName: "eye"),
        Goal(title: "Developing", statusImageName: "Green", viewerImageName: "crown")
    ]
        static let checkInGroupGoals: [Goal] = [
        Goal(title: "Developing", statusImageName: "Checkbox_A", viewerImageName: "crown"),
        Goal(title: "Developing", statusImageName: "Checkbox_", viewerImageName: "eye"),
        Goal(title: "Developing", statusImageName: "Checkbox_B", viewerImageName: "crown"),
        Goal(title: "Developing", statusImageName: "Checkbox_A", viewerImageName: "crown"),
        Goal(title: "Developing", statusImageName: "Checkbox_A", viewerImageName: "crown"),

    ]
    static let checkInIndividualGoals: [Goal] = [
        Goal(title: "Developing", statusImageName: "Checkbox_A", viewerImageName: ""),
        Goal(title: "Developing", statusImageName: "Checkbox_", viewerImageName: ""),
        Goal(title: "Developing", statusImageName: "Checkbox_B", viewerImageName: ""),
        Goal(title: "Developing", statusImageName: "Checkbox_A", viewerImageName: ""),
        Goal(title: "Developing", statusImageName: "Checkbox_A", viewerImageName: ""),
        Goal(title: "Developing", statusImageName: "Checkbox_A", viewerImageName: ""),
        Goal(title: "Developing", statusImageName: "Checkbox_A", viewerImageName: "")
    ]
    
}
