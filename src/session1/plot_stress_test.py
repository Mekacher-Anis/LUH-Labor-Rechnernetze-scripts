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