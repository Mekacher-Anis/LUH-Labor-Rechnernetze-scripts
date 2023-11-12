import matplotlib.pyplot as plt
import pandas as pd


for i, style in [(1, 'r'), (2, 'b--'), (4, "g-.")]:
    # CSV-Datei importieren
    df = pd.read_csv(f"./output/iperf_tcp_receiver1_{i}.csv", delimiter=",")
    data = df.to_numpy()

    # Durchsatzwerte extrahieren
    tp = data[:60, 2]
    tp_avg = data[61, 2]

    # Durchsatzwerte in Mbps umrechnen
    tp = tp / 1000000
    tp_avg = tp_avg / 1000000

    # Durchsatzverlauf plotten
    plt.plot(tp, style)

    # Durchsatzdurchschnitt ausgeben
    print(f'Average transfer rate for {i} parallel streams: ', tp_avg)

plt.xlabel("Time (s)")
plt.ylabel("Throughput (Mbps)")
plt.show()


df = pd.read_csv(f"./output/timestamp_and_cwnd_value_reno_udp_sender1.log", delimiter=",")
data = df.to_numpy()
ax = df.plot(x=0, y=1, label=f'Sender 1', style='r')

# tp = data[:, 1]
# plt.plot(tp, 'r', label='Sender 1')


# df = pd.read_csv(f"./output/timestamp_and_cwnd_value_reno_cubic_sender2.log", delimiter=",",names=['shit', 'test'])
# data = df.to_numpy()
# df['shit'] = df['shit'] - 30
# df.plot(x=0, y=1, label=f'Sender 2', ax=ax, style='b--')
# tp = data[:, 1]
# plt.plot(tp, 'b', label='Sender 1')

# Durchsatzdurchschnitt ausgeben
# plt.xlabel("Kernel Timestamp (s)")
# plt.ylabel("Congestion Window (packet)")
# plt.show()