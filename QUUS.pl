#!/usr/bin/perl
use feature "switch";
no warnings;

sub tagged {
  return {
    tag => $_[0],
    args => $_[1]
  };
}




sub lit {
  return tagged("lit", $_[0]);
}

sub any {
  return tagged("any", 0);
}

sub seq {
  return tagged("seq", [$_[0], $_[1]]);
}

sub alt {
  return tagged("alt", [$_[0], $_[1]]);
}

sub opt {
  return tagged("opt", $_[0]);
}

sub rep {
  return tagged("rep", $_[0]);
}



sub pretty_regex {
  my $regex = $_[0];
  
  for ($regex->{'tag'}) {
    
    when ("lit") {
      return $regex->{'args'};
    }
    
    when ("any") {
      return ".";
    }
    
    when ("seq") {
      return "(" . pretty_regex($regex->{'args'}[0]) .
               pretty_regex($regex->{'args'}[1]) . ")";
    }
    
    when ("alt") {
      return "(" . pretty_regex($regex->{'args'}[0]) . "|" .
               pretty_regex($regex->{'args'}[1]) . ")";
    }
    
    when ("opt") {
      return pretty_regex($regex->{'args'}) . "?";
    }
    
    when ("rep") {
      return pretty_regex($regex->{'args'}) . "+";
    }
    
  }
}

sub generate_string {
  my $regex = $_[0];
  
  for ($regex->{'tag'}) {
    
    when ("lit") {
      return $regex->{'args'};
    }
    
    when ("any") {
      return substr("abcdefghijklmnopqrstuvwxyz", rand(26), 1);
    }
    
    when ("seq") {
      return generate_string($regex->{'args'}[0]) .
             generate_string($regex->{'args'}[1]);
    }
    
    when ("alt") {
      if (0.5 <= rand(1)) {
        return generate_string($regex->{'args'}[0]);
      } else {
        return generate_string($regex->{'args'}[1]);
      }
    }
    
    when ("opt") {
      if (0.5 <= rand(1)) {
        return generate_string($regex->{'args'});
      } else {
        return "";
      }
    }
    
    when ("rep") {
      my $acc = "";
      for my $i (1 .. rand(10)) {
        $acc .= generate_string($regex->{'args'});
      }
      
      return $acc;
    }
    
  }
}

sub generate_regex {
  my $depth = $_[0];
  if ($depth == 0) {
    # return a lit or any
    if (0.5 <= rand(1)) {
      return any();
    } else {
      return lit(substr("abcdefghijklmnopqrstuvwxyz", rand(26), 1));
    }
  } else {
    my $r = rand(6);
    
    if ($r < 1) {
      return any();
    }
    
    if ($r < 2) {
      return lit(substr("abcdefghijklmnopqrstuvwxyz", rand(26), 1));
    }
    
    if ($r < 3) {
      return seq(generate_regex($depth-1), generate_regex($depth-1));
    }
    
    if ($r < 4) {
      return alt(generate_regex($depth-1), generate_regex($depth-1));
    }
    
    if ($r < 5) {
      return opt(generate_regex($depth-1));
    }
    
    if ($r < 6) {
      return rep(generate_regex($depth-1));
    }
    
  }
}







print <<'PREAMBLE'

Welcome to ...

                                             !!!
                                            !!!!!
   QQQ     UUU   UUU  UUU   UUU     SSSS    !!!!!
 QQQQQQQ   UUU   UUU  UUU   UUU   SSSSSSSS  !!!!!
QQQ   QQQ  UUU   UUU  UUU   UUU  SSS        !!!!!
QQQ   QQQ  UUU   UUU  UUU   UUU   SSSSSS    !!!!!
QQQ   QQQ  UUU   UUU  UUU   UUU    SSSSSS    !!!
QQQ   QQQ  UUU   UUU  UUU   UUU        SSS  
 QQQQQQQ    UUUUUUU    UUUUUUU   SSSSSSSS    !!!
   QQQ        UUU        UUU       SSSS      !!!
   QQQ
    QQQ

A Wittgensteinian game about regular expressions!

We'll generate a random pair of regular expressions, the Goal and the
Distractor, and then show you ten strings that the Goal will match. Then
we'll show you some more strings, that are randomly generated by either
the Goal or the Distractor. You have to decide whether or not the Goal
was responsible for the string.

Keep in mind! This is technically impossible! (Kripke, 1982)

Good luck!

PREAMBLE
;

my $regex_goal = generate_regex(5);

my $regex_distractor = generate_regex(5);
while ($regex_goal == $regex_distractor) {
  $regex_distractor = generate_regex(5);  
}

print "\nHere are 10 strings randomly generated by the regular expression:\n\n";

for my $i (0..9) {
  print $i . ": " . generate_string($regex_goal) . "\n\n";
}

print "Here are some more strings. Are they also generated by the regular expression?\n(y/n)\n\n";

my $score = 0;

for (0..9) {
  
  my $answer = 0;
  if (0.5 <= rand()) {
    print "How about '" . generate_string($regex_distractor) . "'? ";
  } else {
    $answer = 1;
    print "How about '" . generate_string($regex_goal) . "'? ";
  }
  
  my $response = "";
  
  while (1) {
    $response = <>;
    if ("y\n" ne $response && "n\n" ne $response) {
      print "That's not a valid response! ";
    } else {
      last;
    }
  }
  
  if ("y\n" eq $response) {
    if (0 == $answer) {
      print "Sorry, that's wrong. :(\n\n";
    } else {
      print "Hooray! You got it! :)\n\n";
      $score += 1;
    }
  }
  
  if ("n\n" eq $response) {
    if (0 == $answer) {
      print "Hooray! You got it! :)\n\n";
      $score += 1;
    } else {
      print "Sorry, that's wrong. :(\n\n";
    }
  }
  
}

print "Your final score is " . $score . "/10!\n";
print "The goal regular expression was /" . pretty_regex($regex_goal) . "/\n";
print "The distractor regular expression was /" . pretty_regex($regex_distractor) . "/\n";
print "Fuuuuuuck Perl!\n\n\n";

print "References\n";
print "----------\n\n";
print "Kripke, Saul. (1982). Wittgenstein on Rules and Private Languages. Harvard\nUniversity Press. ISBN 0-674-95401-7.\n\n\n";
