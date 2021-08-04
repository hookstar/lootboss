using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using Discord;
using System.IO;

namespace lootBoss.Modules
{
    public class ScreenShot
    {
        public bool isBusyUploading;
        public async Task PostScreenShot()
        {
            List<string> newImageReference = new List<string>();
            var bigKill = "../killcam.txt";
            if (new FileInfo(bigKill).Length != 0)
            {
                isBusyUploading = true;
                foreach (string line in File.ReadLines(bigKill, Encoding.UTF8))
                {
                    newImageReference.Add(line);
                }
            }
            //File.WriteAllText(bigKill, string.Empty);
            while (newImageReference.Count != 0)
            {
                foreach (string value in newImageReference)
                {
                    try
                    {
                        var ssPath = "../../../screenshots/";

                        var encounterTime = value.Substring(0, 7);
                        var ssName = value.Substring(value.Length - 23, 23);
                        var enemyName = value.Substring(8, (value.Length - (2 + ssName.Length + encounterTime.Length)));
                        var ssFullPath = ssPath + ssName;

                        var embed = new EmbedBuilder();
                        embed.WithTitle("CONGRATULATIONS... You defeated a monster!");
                        embed.AddField("**Boss Name:**", enemyName, true);
                        embed.AddField("**Clear Time:**", encounterTime, true);
                        embed.WithThumbnailUrl("");
                        embed.WithColor(new Color(54, 57, 63));
                        embed.WithCurrentTimestamp();
                        embed.WithImageUrl($"attachment://{ssName}");

                        var client = Global.Client;
                        ulong channelID = Convert.ToUInt64(Config.bot.discordChannel);
                        var DropChannel = client.GetChannel(channelID) as IMessageChannel;
                        await DropChannel.SendFileAsync(ssFullPath, embed: embed.Build());
                        File.WriteAllText(bigKill, string.Empty);
                        Console.ForegroundColor = ConsoleColor.Green;
                        Console.WriteLine($"Posted " + ssName + " without any error!");
                        Console.ResetColor();
                    }
					
                    catch (Exception)
                    {
                        Console.ForegroundColor = ConsoleColor.Cyan;
                        Console.WriteLine("Screenshot found in killcam.txt - but the file is busy... Retrying.");
                        Console.ResetColor();
                    }
                    isBusyUploading = false;
                }
                break;
            }
        }
    }
}