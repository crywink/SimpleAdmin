return function() -- Wrapping in function so that we have access to the environment
    return {
        {
            Name = "Level";
            TakesArgument = true;
        },
        {
            Name = "Bypass";
            TakesArgument = false;
        },
        {
            Name = "Delay";
            TakesArgument = true;
            Run = function(Time)
                wait(Time)
            end
        }
    }
end