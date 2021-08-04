using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using Discord;
using System.IO;

namespace lootBoss.Modules
{
    public class Drop
    {
        public async Task PostDrops()
        {
            List<string> newDrops = new List<string>();
            var dropFile = "../dropreport.txt";
            if (new FileInfo(dropFile).Length != 0)
            {
                foreach (string line in File.ReadLines(dropFile, Encoding.UTF8))
                {
                    newDrops.Add(line);
                }
            }
            File.WriteAllText(dropFile, string.Empty);
            if (newDrops.Count != 0)
            {
                foreach (string value in newDrops)
                {
                    var client = Global.Client;
                    ulong channelID = Convert.ToUInt64(Config.bot.discordChannel);
                    var DropChannel = client.GetChannel(channelID) as IMessageChannel;
                    await DropChannel.SendMessageAsync($"```css\n" + value + $"\n```");
                }
            }
        }
        /*public async Task PostDrops()
        {
            List<string> newDrops = new List<string>();
            var dropFile = "../dropreport.txt";
            if (new FileInfo(dropFile).Length != 0)
            {
                foreach (string line in File.ReadLines(dropFile, Encoding.UTF8))
                {
                    newDrops.Add(line);
                }
            }
            File.WriteAllText(dropFile, string.Empty);
            if (newDrops.Count != 0) //need to add a marker from the windower client when the pool is empty
            {
                var zws = "\u200B";
                var embed = new EmbedBuilder();
                foreach (string value in newDrops)
                {
                    var playerName = value.Substring(1, (value.IndexOf("]") - 1));
                    var itemName = value.Substring(value.LastIndexOf(">") + 1, (value.Length - (value.LastIndexOf(">") + 1)));
                    embed.AddField(itemName, playerName, true);
                }
                if (newDrops.Count == 2 || newDrops.Count == 5 || newDrops.Count == 8)
                {
                    embed.AddField(zws, zws, true);
                }
                var client = Global.Client;
                ulong channelID = Convert.ToUInt64(Config.bot.discordChannel);
                var DropChannel = client.GetChannel(channelID) as IMessageChannel;
                await DropChannel.SendMessageAsync("", false, embed.Build());
            }
        }*/
    }
} 