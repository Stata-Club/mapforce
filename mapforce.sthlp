{smcl}
{* 15Jan2017}{...}
{hi:help mapforce}
{hline}

{title:Title}

{phang}
{bf:mapforce} {hline 2} Echarts diagram, draw a force guide layout.Firefox is recommended.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:mapforce} {it:varlist} {ifin} {it:using filename} {cmd:,} [{it:options}]

{marker description}{...}
{title:Description}

{pstd}
{cmd:mapforce} need five variables, source, target, source category, target category, relationship value.In addition, source and target must be string variables. 
source categories, target categories and relationship value must be numeric variables,{cmd:mapforce} can draw an echarts diagram. {p_end}


{marker options}{...}
{title:Options for mapforce}

{phang}
{opt replace} permits to overwrite an existing file. {p_end}

{marker example}{...}
{title:Example}

{pstd}Change the working path to e disk.

{phang}
{stata `"cd e:/"'}
{p_end}

{pstd}Download the sample data to the e disk.

{phang}
{stata `"copy "https://github.com/Stata-Club/Sharing-Center-of-Stata-Club/blob/master/article/%E6%A0%B7%E6%9C%AC.dta?raw=true" e:/sample.dta,replace"'}
{p_end}

{pstd}Read the sample data into memory.

{phang}
{stata `"use sample.dta,clear"'}
{p_end}

{pstd}draw a Echarts diagram 

{phang}
{stata `"mapforce source target group group1 value using mapforce.html,replace "'}
{p_end}

{pstd}open the mapforce.html

{phang}
{stata `"shellout mapforce.html"'}
{p_end}

{title:Author}

{pstd}Chuntao LI{p_end}
{pstd}China Stata Club(爬虫俱乐部){p_end}
{pstd}Wuhan, China{p_end}
{pstd}chtl@zuel.edu.cn{p_end}

{pstd}Ming WANG{p_end}
{pstd}China Stata Club(爬虫俱乐部){p_end}
{pstd}Wuhan, China{p_end}
{pstd}18895616030@163.com{p_end}

