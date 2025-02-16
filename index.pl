#! C:\Perl64\bin\perl.exe
## /usr/bin/perl

#########
#INSPIRATION .01
#Code by https://www.lostways.com
#Email: andrew@lostways.com
#########

use LWP::UserAgent;
use CGI;

#CC Catalog API
$CCApiUrl = $ENV{'HTTP_CC_API_URL'};
$CCApiToken = $ENV{'HTTP_CC_API_TOKEN'};

#SEO Tools
$verifyV1 = $ENV{'HTTP_VERIFY_v1'}; 
$yKey = $ENV{'HTTP_Y_KEY'}; 
$msvalidate = $ENV{'HTTP_MSVALIDATE'}; 
$ga = $ENV{'HTTP_GA'}; 

$wordlist="dicts/6of12.txt";

$browser = LWP::UserAgent->new;
$browser->agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.77 Safari/537.36");

$cgi = new CGI;

srand;

if ($cgi->param("word"))
{
	
	open WORDS, $wordlist or die "Cant open word list: $!\n";	

	$param_word = $cgi->param("word");
	$param_word =~ s/[^A-Za-z0-9 ]*//gi;
	
	if (grep{/$param_word/} <WORDS>) {
		$word = $param_word;
	} else {
		$word = GetWord();
	}
	
}
else
{
	$word = GetWord();
}

$time = time;

@imgArray = GetCCImg();
$displayImg = $imgArray[0];
$imgUrl = $imgArray[1];
$definitionCode = GetDefinition();

$debug = $imgArray[2];

###############
#Create page
##########
print "Content-type: text/html\n\n";

print <<WebPage;

<html>
<head>

<title>Randomword.net - Random Word & Image Generator</title>
<meta name="verify-v1" content="$verifyV1" >
<meta name="y_key" content="$yKey">
<meta name="msvalidate.01" content="$msvalidate" />

<script language="JavaScript">
<!--
function openWin(URL) {
	w=window.open(URL,"newwindow","toolbar=no, width=350, height=400, status=no, scrollbars=yes, resize=no, menubar=no");
}
//-->
</script>
<script data-ad-client="ca-pub-0492203084296419" async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
<!-- Global site tag (gtag.js) - Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=$ga"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

  gtag('config', '$ga');
</script>

</head>

<body>
<link REL=stylesheet HREF="random-word.css" TYPE="text/css">
<div id=content>
<div id=main-content style="">
<center>
		<h1>
			Random Word and Random Image Generator
		</h1>
		<div>
		</div>
		<p>
		<div id=description>
		This site generates a random word, shows the definition, and displays a creative commons image result for that word.
		If you find an interesting/funny/ridiculous word-image combination, click on "Link to current word" and copy the url to share.
		</div>
		<div id=navbar>
			<a href=\"/?$time\" title="New Word">New Word</a> | 
			<a href=\"/?word=$word\" title="Link To Current Word">Link to current word</a>
		</div>

		<div id=word>
			<h2> $word </h2>
		</div>
		<p>
		<div id=image>	
			<a href="$imgUrl">$displayImg</a>
		</div>	
		<div id=word>
			<h2> $word </h2>
		</div>
		<div id=googleadd>
		</div>	
		<div id=definition>
			$definitionCode
		</div>
		
		</center>
</div>
<hr>
<div id=footer style="vertical-align: bottom;">

 <p>
 Created by <a href="https://github.com/lostways/">Andrew Lowe</a> in 2007 with Perl.
 </p>
 <p>
 [Credits]
</p>
<p>
Word List: 6of12.txt from the 12dicts project by Alan Beale<br />
Definition: https://www.dict.org <br />
Image: https://openverse.org/ <br />
</p>

</div>
</div>

$debug


</body>

</html>
WebPage


#################
#Subroutines
###############

sub GetWord {
	open WORDS, $wordlist or die "Cant open word list: $!\n";
	rand($.) <1 && ($word=$_) while <WORDS>; #get random word

	#strip word of any extra characters
	$word=~s/[^\w- ]//g;
	
	return $word;
}

sub GetDefinition {
	
	$dictURL='http://www.dict.org/bin/Dict?Form=Dict1&Query=' . $word . '&Strategy=*&Database=*';
	
	$resp = $browser->get($dictURL) or die "cant open $!\n";
	$defpage = $resp->as_string;
	
	$defpage =~/<hr>(.*)<hr>/s;

	$definition = $1;

	$definition =~s/<a href=\"(.*?)\">/<a href=\"http:\/\/www.dict.org\1\" target=new>/g;

	return $definition;
} #end GetDefinition

sub GetCCImg {

	$debug = '';

	$imgSearchURL = $CCApiUrl . '/v1/images?size=small&page_size=1&q=' . $word;

	$resp = $browser->get($imgSearchURL);
	$imgPage = $resp->decoded_content;
	#$debug = $imgPage;

	$imgPage =~ /\"url\":\"(.*?)\"/;
	$imgrURL = $1;

	$imgPage =~ /foreign_landing_url\":\"(.*?)\"/;
	$imgrOrgURL = $1;		
	
	$imgTag = "<img alt=\"random image word $word\" src=\"$imgrURL\" />"; 
	@img = ($imgTag,$imgrOrgURL,$debug);
	
	return @img;
} # end GetImg

