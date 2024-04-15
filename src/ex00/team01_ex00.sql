create or replace view last_currency_udated as
	(select t1.id, t1.name,  t1.rate_to_usd, t1.updated
	from currency t1, (select name, max(updated) as updated
					   from currency
					  group by name) t2
	where t1.name = t2.name and t1.updated = t2.updated);

select
	coalesce("user".name, 'not defined') as name,
	coalesce("user".lastname, 'not defined') as lastname,
	balance.type,
	sum(balance.money) as volume,
	coalesce(last_currency_udated.name, 'not defined') as currency_name,
	coalesce(last_currency_udated.rate_to_usd, 1::numeric) as last_rate_to_usd,
	sum(balance.money) * coalesce(last_currency_udated.rate_to_usd, 1::numeric) as total_volume_in_usd
from
	"user"
right join balance on "user".id = balance.user_id
full join last_currency_udated on last_currency_udated.id = balance.currency_id
group by "user".id, balance.type, last_currency_udated.name, last_currency_udated.rate_to_usd
order by 1 desc, 2, 3