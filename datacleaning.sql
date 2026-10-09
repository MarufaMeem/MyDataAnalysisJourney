CREATE TABLE `layoff_staging_dup` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `r_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

insert into layoff_staging_dup
select *,
row_number() over(partition by  company,industry,total_laid_off,percentage_laid_off,`date`,location,stage,country,funds_raised_millions) as r_num
from layoff_staging;


select *
from layoff_staging_dup;

SET SQL_SAFE_UPDATES = 0;
delete 
from layoff_staging_dup
where r_num>1;

select count(*)
from layoff_staging_dup
where r_num>1;


#standardization :
update layoff_staging_dup
set company=trim(company);

update layoff_staging_dup
set industry='Crypto'
where industry like 'Crypto%';

update layoff_staging_dup
set country=trim(trailing '.' from country);
select country
from layoff_staging_dup;

update layoff_staging_dup
set `date` = str_to_date(`date`,'%m/%d/%Y/');
select `date`
from layoff_staging_dup;

update layoff_staging_dup t1
join layoff_staging_dup t2
on t1.company=t2.company
set t1.industry=t2.industry
where (t1.industry is null or t1.industry=' ')
and t2.industry is not null;

delete
from layoff_staging_dup
where total_laid_off is null
and percentage_laid_off is null;

alter table layoff_staging_dup
drop column r_num;