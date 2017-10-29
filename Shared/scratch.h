
act : ask ~ (show | hide | setting | clear) {
    
    ask  : "klio" ~ "please"?
    show : ("show" | "reveal") type
    hide : ("hide" | "remove") type
    all  : "all"
    
    setting : "set" (speech | debug) onoff {

        speech : "speaker" | "speech"
        debug : "debug"
        onoff : "on" | "off"
    }
    clear : "clear" "all"? type
    
    refresh : ("refresh" | "reset") "screen"?
    type : all? ("alarms" | "marks")
}

sentence : ignore ~ (movie | music | search | change) {
    
    movie : ask (title | director | actors+) {
        
        ask      : ("show" | "watch") "movie"?
        title    : "title" movieTitle() | director
        director : ("directed" | "shot")? "by"? "with"? Director
        actors   : (with | acted by | starring) Actor
        Director : "\\file:movieDirectors.csv"
        Actor    : "\\file:moveActor.csv"
    }
    
    music : (ask | search) type? music {
        
        ask : "play" | "listen" "to"
        
        search : "please"? ~ search type {
            
            search : "find" | "search" | "look" "for"
            type   : "song" | "movie"
        }
        type : artist | genre | track trackNum  {
            
            track : next | prev | goto {
                
                next : goto? "next" ("song" | "track")
                prev : goto? "previous" ("song" | "track")
                goto : "go" "to" | "go" "play" "the"?
            }
            genre  : "genre" Genre
            artist : ("artist" | ("performed" | "played") "by") Artist())
            Artist : "\\file:musicArtist.csv"
            Genre  : "\\file:musicGenre.csv"
        }
    }
    
    change : volume | balance {
        
        volume : ask amount? ("louder" | "quieter") {
            
            ask : "make" "the"? ("music" | "sound")
            amount : "a" "little" | "much" | "a" "lot"
        }
        balance : "set"? pan amount {
            pan : "balance" | "pan"
            amount : "left" | "center" | "right"
        }
    }
    
    ignore : "please"? ~ (("would" | "will" | "could")? "you"? | "I" "want" "to" "get"? "some"?)
    
    trackNum : digits | (zero ~ ones ~ teen ~ tens) {
        
        zero : "zero" | "oh" | "zed"
        ones : "one" | "two" | "three" | "four" | "five" | "six" | "seven" | "eight" | "nine"
        teen : "ten" | "eleven" | "twelve" | "thirteen" | "fourteen" | "fifteen" | "sixteen" | "seventeen" | "eighteen" | "nineteen"
        tens | "twenty" | "thirty" | "fourty" | "fifty" | "sixty" | "seventy" | "eighty" | "ninety"
        digits : '[0-9]{1,5}'
    }
    
}

✏ Clear clear all marks
Clear clear all marks
{0,11} t:0.76 d:0.90 c:0.51 "Clear clear","Klio clear","Cleo clear","Khleo clear","Kaleo clear","Clio clear"
{12,15} t:1.66 d:0.18 c:0.90 "all"
{16,21} t:1.84 d:0.68 c:0.57 "marks","Marx"
Klio clear all marks
{0,10} t:0.76 d:0.90 c:0.51 "Klio clear","Clear clear","Cleo clear","Khleo clear","Kaleo clear","Clio clear"
{11,14} t:1.66 d:0.18 c:0.90 "all"
{15,20} t:1.84 d:0.68 c:0.57 "marks","Marx"
Cleo clear all marks
{0,10} t:0.76 d:0.90 c:0.51 "Cleo clear","Clear clear","Klio clear","Khleo clear","Kaleo clear","Clio clear"
{11,14} t:1.66 d:0.18 c:0.90 "all"
{15,20} t:1.84 d:0.68 c:0.57 "marks","Marx"
Khleo clear all marks
{0,11} t:0.76 d:0.90 c:0.51 "Khleo clear","Clear clear","Klio clear","Cleo clear","Kaleo clear","Clio clear"
{12,15} t:1.66 d:0.18 c:0.90 "all"
{16,21} t:1.84 d:0.68 c:0.57 "marks","Marx"
Kaleo clear all marks
{0,11} t:0.76 d:0.90 c:0.51 "Kaleo clear","Clear clear","Klio clear","Cleo clear","Khleo clear","Clio clear"
{12,15} t:1.66 d:0.18 c:0.90 "all"
{16,21} t:1.84 d:0.68 c:0.57 "marks","Marx"
Clio clear all marks
{0,10} t:0.76 d:0.90 c:0.51 "Clio clear","Clear clear","Klio clear","Cleo clear","Khleo clear","Kaleo clear"
{11,14} t:1.66 d:0.18 c:0.90 "all"
{15,20} t:1.84 d:0.68 c:0.57 "marks","Marx"
Clear clear all Marx
{0,11} t:0.76 d:0.90 c:0.51 "Clear clear","Klio clear","Cleo clear","Khleo clear","Kaleo clear","Clio clear"
{12,15} t:1.66 d:0.18 c:0.90 "all"
{16,20} t:1.84 d:0.68 c:0.57 "Marx","marks"

