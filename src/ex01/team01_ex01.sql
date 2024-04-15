-- 2 параметра: идентификатор валюты и время обновления баланса
CREATE OR REPLACE FUNCTION func_rate_min(p_currency_id integer, p_balance_updated timestamp)
RETURNS numeric AS $$
DECLARE
    v_rate numeric;
BEGIN
-- Если не существует валюта с заданным id, возвращается 1
    IF (SELECT count(*)
        FROM currency
        WHERE currency.id = p_currency_id) = 0 THEN
        v_rate = 1.0;
    ELSE
  -- выбирает последний курс к доллару,
  -- который был обновлён до времени p_balance_updated
        SELECT rate_to_usd
            INTO v_rate -- присваиваем значение v_rate из запроса SELECT rate_to_usd
        FROM currency
        WHERE currency.id = p_currency_id
            AND currency.updated <= p_balance_updated
        ORDER BY updated DESC
        LIMIT 1;

        -- если не удалось найти курс к доллару
    -- выбираем первый курс для данной валюты
    IF v_rate IS NULL THEN
            SELECT rate_to_usd
                INTO v_rate
            FROM currency
            WHERE currency.id = p_currency_id
            ORDER BY updated
            LIMIT 1;
        END IF;
    END IF;

    RETURN v_rate;
END;
$$ LANGUAGE 'plpgsql';


SELECT DISTINCT coalesce("user".name, 'not defined') AS name,
       coalesce("user".lastname, 'not defined') AS lastname,
       currency.name AS currency_name,
       (money * func_rate_min(currency_id, balance.updated)) AS currency_in_usd
FROM balance
    FULL JOIN "user" ON balance.user_id = "user".id
    JOIN currency ON balance.currency_id = currency.id
ORDER BY 1 DESC, 2, 3;