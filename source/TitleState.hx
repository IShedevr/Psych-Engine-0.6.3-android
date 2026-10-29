package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.system.FlxSound;
import openfl.display.BlendMode;

class TitleState extends MusicBeatState
{
    public static var initialized:Bool = false;
    public static var closedState:Bool = false;

    public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
    public static var volumeDownKeys:Array<FlxKey> = [FlxKey.MINUS, FlxKey.NUMPADMINUS];
    public static var volumeUpKeys:Array<FlxKey> = [FlxKey.PLUS, FlxKey.NUMPADPLUS];

    var logo:FlxSprite;
    var start:FlxSprite;
    var glow:FlxSprite;
    var entered:Bool = false;
    var confirmSound:FlxSound;

    override public function create():Void
    {
        #if android
        FlxG.android.preventDefaultKeys = [BACK];
        #end

        // Keep Psych Engine's normal initialization and preferences.
        super.create();
        Paths.clearStoredMemory();
        Paths.clearUnusedMemory();
        WeekData.loadTheFirstEnabledMod();
        PlayerSettings.init();
        FlxG.save.bind('funkin', CoolUtil.getSavePath());
        ClientPrefs.loadPrefs();
        Highscore.load();

        if (FlxG.sound.music == null)
            FlxG.sound.playMusic(Paths.music('menu'), 1, true);

        // Full custom title screen: no original GF/logo intro.
        var bg = makeSprite('menus/title/bg');
        bg.scrollFactor.set(0.2, 0.2);
        add(bg);

        var pillar3 = makeSprite('menus/title/pillar-3');
        pillar3.scrollFactor.set(0.3, 0.3);
        add(pillar3);

        var pillar2 = makeSprite('menus/title/pillar-2');
        pillar2.scrollFactor.set(0.4, 0.4);
        add(pillar2);

        var pillar1 = makeSprite('menus/title/pillar-1');
        pillar1.scrollFactor.set(0.5, 0.5);
        add(pillar1);

        var pillarMid = makeSprite('menus/title/pillar-mid');
        add(pillarMid);

        var pillarEdge = makeSprite('menus/title/pillar-edge');
        add(pillarEdge);


        logo = makeSprite('menus/title/logo');
        add(logo);

        glow = new FlxSprite(FlxG.width / 2 - 1164 / 2, FlxG.height);
        glow.loadGraphic(Paths.image('menus/title/start-glow'));
        glow.blend = BlendMode.ADD;
        glow.color = 0xFFF2004C;
        add(glow);

        start = new FlxSprite();
        start.loadGraphic(Paths.image('menus/title/start'));
        start.setPosition(glow.x + 382, glow.y + 114);
        add(start);

        var vignette = makeSprite('menus/title/vignette');
        vignette.scrollFactor.set();
        add(vignette);

        for (sprite in [bg, pillar3, pillar2, pillar1, pillarMid, pillarEdge, logo, glow, start, vignette])
            sprite.antialiasing = ClientPrefs.globalAntialiasing;


        FlxG.camera.zoom = 1.25;
    }

    function makeSprite(key:String):FlxSprite
    {
        var spr = new FlxSprite();
        spr.loadGraphic(Paths.image(key));
        spr.screenCenter();
        return spr;
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (!entered)
        {
            FlxG.camera.scroll.x = FlxMath.lerp(FlxG.camera.scroll.x,
                (FlxG.mouse.screenX - FlxG.width / 2) * 0.015, elapsed * 8);
            FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y,
                (FlxG.mouse.screenY - 6 - FlxG.height / 2) * 0.015, elapsed * 8);
        }
        else
        {
            FlxG.camera.scroll.x = FlxMath.lerp(FlxG.camera.scroll.x, 0, elapsed * 8);
            FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, 0, elapsed * 8);
        }

        if (!entered && (controls.ACCEPT || FlxG.mouse.justPressed))
        {
            entered = true;
            glow.color = FlxColor.WHITE;
            confirmSound = FlxG.sound.play(Paths.sound('menu/confirm'));
            FlxG.camera.fade(FlxColor.BLACK, 0.6);
            new FlxTimer().start(0.6, function(_)
            {
                FlxG.switchState(new MainMenuState());
            });
        }

        FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, 1.25, 0.04);
        logo.y = FlxMath.lerp(logo.y, FlxG.height / 2 - logo.height / 2 + (entered ? 0 : -50), 0.04);
        glow.y = FlxMath.lerp(glow.y, entered ? FlxG.height : FlxG.height - 316, 0.04);
        start.setPosition(glow.x + 382, glow.y + 114);

        if (entered) glow.alpha = FlxMath.lerp(glow.alpha, 0.1, 0.04);
    }
}
