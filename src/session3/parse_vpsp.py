#!/usr/bin/env python3

import numpy as np

traceroute_output_files = [
    './output/vpsp/sender1_receiver1_28.csv',
    './output/vpsp/sender1_receiver1_500.csv',
    './output/vpsp/sender1_receiver1_1000.csv'
]

hops = ['Router1', 'Router2', 'Receiver1']

data = np.zeros((len(traceroute_output_files), len(hops), 10))

for file_idx, file in enumerate(traceroute_output_files):
    print(f'\n\n{file}')
    with open(file) as f:
        lines = f.readlines()
        if len(lines) != 3:
            raise 'ERROR: unexpected 3 lines in file'
        for i,line in enumerate(lines):
            line = line.strip()
            if line.startswith('traceroute'):
                continue
            line = line.split(',')
            parts = []
            for part in line:
                if 'ms' not in part:
                    continue
                parts.append(part.split(' ')[0])
            if len(parts) != 10:
                raise ValueError(f'ERROR: Hops {hops[i]} has {len(parts)} parts instead of 10')
            
            # print min, mean, median of parts
            parts = [float(part) for part in parts]
            min_part = round(min(parts), 3)
            mean_part = round(sum(parts)/len(parts), 3)
            median_part = round(sorted(parts)[len(parts)//2], 3)
            data[file_idx][i] = parts
            print(f'{hops[i]}: min= {min_part}, mean= {mean_part}, median= {median_part}')

# get the alpha values from the measurements with small packet size
alphas = np.min(data[0], axis=1) / 2
print('\nAlpha values : ', alphas)
betas = np.zeros((len(traceroute_output_files), len(hops)))

for i, l in [(1, 500), (2, 1000)]:
    print(f'\n\nPacket size {l} bytes')
    for hop in range(len(hops)):
        print(f'Hop : {hops[hop]}')
        rtts = data[i][hop]
        owd = np.min(rtts) / 2
        beta = owd - alphas[hop]
        C = l / (beta - betas[i][max(0,hop-1)])
        betas[i][hop] = beta
        print(f'OWD : {round(owd, 3)} ms / Alpha: {alphas[hop]} ms / Beta : {round(beta, 3)} ms / C : {round(C*8/1000, 3)} Mbit/s')