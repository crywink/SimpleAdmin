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
        Run = function(CommandData, Time)
            wait(Time)
        end
    }
}