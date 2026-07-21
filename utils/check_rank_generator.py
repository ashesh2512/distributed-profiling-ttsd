from rank_generator import RankGenerator

rg = RankGenerator(
  tp=2,
  dp=8,
  pp=1,
  cp=2,
  order='tp-cp-pp-dp',
)

print(rg.get_ranks('dp'))
print(rg.get_ranks('tp'))
print(rg.get_ranks('cp'))
