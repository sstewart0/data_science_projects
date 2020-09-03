import pandas as pd
from mlxtend.frequent_patterns import apriori, fpgrowth
from mlxtend.preprocessing import TransactionEncoder
from itertools import chain, permutations

# apriori & fpgrowth take a (pandas) binary transaction table, i.e.
#
#               Item
# Transaction   Eggs    Ham     Cheese
#          11   True    True    False
#          12   False   True    False
#
# We can create this using the libraries built in TransactionEncoder function

# Data for Q1 (apriori & fpgrowth)
transaction_data = [['A', 'B', 'C', 'D'],
                    ['A', 'C', 'D', 'F'],
                    ['A', 'C', 'D', 'E', 'G'],
                    ['A', 'B', 'D', 'F'],
                    ['B', 'C', 'G'],
                    ['D', 'F', 'G'],
                    ['A', 'B', 'G'],
                    ['C', 'D', 'F', 'G']]

# Data for Q4: association rules
transaction_data2 = [['A', 'C', 'D'],
                     ['B', 'C', 'E'],
                     ['A', 'B', 'C', 'E'],
                     ['B', 'D', 'E'],
                     ['A', 'B', 'C', 'E'],
                     ['A', 'B', 'C', 'D']]


# Re-write itertools.combinations function to return list of list of strings not list of tuples of strings
def combinations(iterable, r):
    pool = tuple(iterable)
    n = len(pool)
    for indices in permutations(range(n), r):
        if sorted(indices) == list(indices):
            yield [pool[i] for i in indices]


# Definition to return antecedents of the frequent itemset (in order of decreasing string length)
def antecedents(freq_itemset):
    s = list(freq_itemset)
    return sorted(chain.from_iterable(combinations(s, r) for r in range(2, len(s))),
                  key=lambda x: len(x), reverse=True)


# Produce power set of itemset
def power_set(itemset):
    s = list(itemset)
    return sorted(chain.from_iterable(combinations(s, r) for r in range(1, len(s)+1)),
                  key=lambda x: len(x))


# Function to calculate support:
def compute_support(item, itemset):
    support = 0
    for i in itemset:
        if len(set(item) - set(i)) == 0:
            support += 1
    return support


# Function to update antecedents by removing all subsets of an item:
def update_antecedents(ants, item):
    powerset = power_set(item)
    for i in powerset:
        if i in ants:
            ants = set(tuple(ant) for ant in ants).difference({tuple(i), })
            ants = [list(x) for x in ants]
    return ants


# Function to return all viable association rules from
def association_rules(freq_itemset, full_itemset, minconf):
    result = []
    antecs = antecedents(freq_itemset)
    support = compute_support(freq_itemset, full_itemset)
    for a in antecs:
        overlap = list(set(freq_itemset).difference(a))
        conf = support/compute_support(overlap, full_itemset)
        if minconf != 0:
            if conf >= minconf:
                result.append([a, overlap, conf])
            else:
                antecs = update_antecedents(antecs, a)
        else:
            result.append([a, overlap, round(conf, 2)])
    return result


# Create the pandas dataframe as described above
te = TransactionEncoder()
binary_data = te.fit(transaction_data).transform(transaction_data)
pandas_df = pd.DataFrame(binary_data, columns=te.columns_)


# Apply apriori & fpgrowth to the pandas dataframe
def main():
    # Q1:
    print("Apriori  with min_support = 3/8: \n")
    print(apriori(pandas_df, min_support=3/8, use_colnames=True))
    print("FPGrowth with min_support = 2/8: \n")
    print(fpgrowth(pandas_df, min_support=2/8, use_colnames=True))
    # Q4:
    print("Association rules in the form: [Antecedent, Target, Confidence]")
    print(association_rules(['A', 'B', 'C'], transaction_data2, 0))


if __name__ == "__main__":
    main()
