\NeedsTeXFormat{LaTeX2e}

\ProvidesClass{tikkun}[2017/12/14 Tikkun Class]

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{extarticle}}
\ProcessOptions\relax
\LoadClass{extarticle}

\extrafloats{1000}

\makeatletter
   \def\marginparright{\@mparswitchfalse}
   \def\marginparoutside{\@mparswitchtrue}
\makeatother

\RequirePackage[letterpaper, nohead, twoside, margin=1in, marginparwidth=0.5in, marginparsep=0.1in]{geometry}
\RequirePackage[dvipsnames]{xcolor}
\RequirePackage{polyglossia}

\setdefaultlanguage{hebrew}
\setmainfont{Shlomo}
\setmonofont{Shlomo Stam}

\setlength\parindent{0pt} % no indent
\pagenumbering{gobble}    % no page number

\newcommand{\pnum}[1]{\hspace{0pt}\marginpar{\textcolor{Gray}{\rmfamily \hebrewnumeral{#1}}}}
\reversemarginpar

\newenvironment{pointed}
{ % ENTER
\setspacing
\newcommand\pespace{\hbox to 5em{\small\hfil{}פ{}\hfil}}
\newcommand\samechspace{\hbox to 3em{\small\hfil{}ס\hfil}}
}
{ % EXIT
}

\newenvironment{torah}
{ % ENTER
\ttfamily
\setspacing
\newcommand\pespace{\par}
\newcommand\samechspace{\hspace{3em}}
}
{ % EXIT
}

\setlength{\parskip}{0pt}
\newcommand\setspacing{
\fontdimen2\font=0.4em% interword space
\fontdimen3\font=\textwidth% interword stretch
\fontdimen4\font=0.2em% interword shrink
\fontdimen7\font=0.1em% extra space
}