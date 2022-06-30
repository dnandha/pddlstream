import sys
import numpy as np


def comp_loc(x, y):
    xs = x.split('|')[1:]
    ys = y.split('|')[1:]
    print(xs, ys)
    for a, b in zip(xs, ys):
        if a == b:
            yield 1
        else:
            yield 0

def comp_coords(x, y):
    xs = np.asarray(x.split('_')[1:][0].split(','), dtype=np.float)
    ys = np.asarray(y.split('_')[1:][0].split(','), dtype=np.float)
    dist = np.linalg.norm(ys-xs)/len(xs)
    return dist


results_file = sys.argv[1]

equals = {}
inequals = {}
totals = {}
nones = 0
ntrials = 0
locs_correct = 0
locs_incorrect = 0

coords_correct = 0
coords_incorrect = 0

with open(results_file) as f:
    for l in f:
        ntrials += 1
        vals = l.split(';')

        if vals[-1].strip() == "" or len(vals) == 1:
            nones += 1
            continue

        x = vals[3].lower().strip()
        y = vals[4].lower().strip()
        if not y in totals:
            totals[y] = 1
        else:
            totals[y] += 1

        if y in x:
            if not y in equals:
                equals[y] = 1
            else:
                equals[y] += 1
        else:
            if not y in inequals:
                inequals[y] = 1
            else:
                inequals[y] += 1

        if len(vals) > 5:
            x_args = [vals[5].lower().strip()]
            y_args = [vals[6].lower().strip()]
            if len(vals) > 7:
                x_args += [vals[-2].lower().strip()]
                y_args += [vals[-1].lower().strip()]

            for x, y in zip(x_args, y_args):
                if x.startswith("loc|"):
                    if not y.startswith("loc|"):
                        locs_incorrect += 1
                        continue

                    if len(x) == 0 or len(y) == 0:
                        locs_incorrect += 1
                        continue

                    comp = list(comp_loc(x, y))
                    if np.sum(comp) == 4:
                        locs_correct += 1
                    else:
                        locs_incorrect += 1
                elif '_' in x:
                    if not '_' in y:
                        coords_incorrect += 1
                        continue

                    dist = comp_coords(x, y)
                    if dist < 0.2:
                        coords_correct += 1
                    else:
                        coords_incorrect += 1




print("equals")
for k in equals:
    print(k, equals[k], totals[k], equals[k]/totals[k]*100)

print("inequals")
for k in inequals:
    print(k, inequals[k], totals[k], inequals[k]/totals[k]*100)

print("nones", nones, ntrials, nones/ntrials*100)

print("locs correct")
print(locs_correct, locs_correct+locs_incorrect, locs_correct/(locs_correct+locs_incorrect)*100)

print("coords correct")
print(coords_correct, coords_correct+coords_incorrect, coords_correct/(coords_correct+coords_incorrect)*100)
