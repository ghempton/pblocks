package pblocks.util
{
	public class Char
	{
		public static function keyCodeToString(keyCode:int):String
		{
			if (keyCode > 64 && keyCode < 91)
		    {
		        var strLow:String = "abcdefghijklmnopqrstuvwxyz";
		        return strLow.charAt(keyCode - 65);
		    }
		    switch(keyCode)
		    {
		    	// TODO: Fill these out
		    	case 38: return "up";
		    	case 40: return "down";
		    	case 37: return "left";
		    	case 39: return "right";
		    	case 36: return "home";
		    	case 32: return "space";
		    	default: return keyCode.toString();
		    }
		}
		
		public static function charCodeToString(charCode:int):String
		{
		    if (charCode > 47 && charCode < 58)
		    {
		        var strNums:String = "0123456789";
		        return strNums.charAt(charCode - 48);
		    }
		    if (charCode > 64 && charCode < 91)
		    {
		        var strCaps:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
		        return strCaps.charAt(charCode - 65);
		    }
		    if (charCode > 96 && charCode < 123)
		    {
		        var strLow:String = "abcdefghijklmnopqrstuvwxyz";
		        return strLow.charAt(charCode - 97);
		    }
		    return charCode.toString();
    	} 
	}
}