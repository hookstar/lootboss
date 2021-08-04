using System;
using System.Threading;
using lootBoss.Modules;

namespace lootBoss
{
    public class TimerService
    {
        public Timer _timer;
        public Drop _drop;
        public ScreenShot _ss;
        public TimerService()
        {
            _ss = new ScreenShot();
            _drop = new Drop();
            _timer = new Timer(async _ =>
            {
                if (_ss.isBusyUploading == false)
                {
                    await _ss.PostScreenShot();
                }
                else
                {
                    Console.ForegroundColor = ConsoleColor.Cyan;
                    Console.WriteLine("TimerService stopped. The previous call is still busy uploading an exisiting stream value.");
                    Console.ResetColor();
                }
                await _drop.PostDrops();
            },
            null,
            TimeSpan.FromSeconds(1),
            TimeSpan.FromSeconds(1));
        }
        public void Stop()
        {
            _timer.Change(Timeout.Infinite, Timeout.Infinite);
        }
    }
}
