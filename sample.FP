CONSTANTS
{ a 5 }

FUNCTIONS
{ factorial val return retval
    { if {< val 5}
      then {= retval -1} 
      else {= retval 1}
           { while {> val 0}
              {= retval {* retval val}}
              {= val {- val 1}}
           }
    }
}

MAIN
{read x}
{= f x}
{ if {< val 5}
      then {= retval -1} 
      else {= retval 1}}
{ while {> val 0}
              {= retval {* retval val}}
              {= val {- val 1}}
           }
{print (Factorial of) x (is) f (n)}
