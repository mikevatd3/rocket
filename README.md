# Rocket

## Setting up the project

1. Clone the repository (using git from the terminal, or [using VSCode](https://code.visualstudio.com/docs/sourcecontrol/repos-remotes)
2. [Install `uv`](https://docs.astral.sh/uv/getting-started/installation/) (if
   you haven't already).
3. `cd` into the repository, or open the VSCode terminal and run the command `uv sync`

## Co-working session log

Here is a brief description of what we did in co-working sessions on each date

### 2026-05-27 City wide sales data

#### Summary

- Looked at sales data across city neighborhoods, dealing with a couple of
  complexities:
  - 1. Sales data from the assessors sales file doesn't split the consideration
       over parcels in multi-parcel transactions
  - 2. Some neighborhoods don't have very many single-family parcels to consider

#### Artifacts

- Chart of sales price change, and volume in each neighborhood showing some big
  jumps in places but a more common trend of modest price growth.

### 2026-05-28 Seeing if we can triangulate SWAPPIES transactions

#### Summary

- We got the study area files prepared and in the rocket schema on IPDS. We then 
  tried to identify sales within the study area related to the SWAPPIES program.
- We looked at sales with grantor or grantee equal to 'UNITED COMMUNITY HOUSING
  COALITION' and found many parcels with UCHC as grantor, but not as many with
  UCHC as grantee, and none that we could find with swapped grantor and grantee
  which you might expect. *Maybe* could use a more fine-grained look, but these
  transactions weren't easily identifiable from the table.

### 2026-06-01 Starting on Median Sales Price

#### Summary

- Organized all current work into this repo.
- Started median sale price queries Danielle on the assessors parcel sales file,
  and Mike on ROD. Didn't finish, but will continue tomorrow.

### 2026-06-02 cut short due to MV internet going out + SDC

### 2026-06-03 Bug Hunting + ACS Pull

#### Summary
- We looked at the script for the boundary pf - adding date type casts
- review Abhi's ACS pull - Q:\3_Projects\ROCKETRUST\Y2 Activity 2 - Alpine-Joy Place-Based Investment Area Analysis\ACS Data Pull
- GEOIDS for the 3 boundaries in three diff tabs - list can be found in task comments

### 2026-06-04 History + DTB final edits to boundary pf

#### Summary
- D3 ID contenxt - developed as way to id parcels that have changed over time
   - start date, end date, parcel id = better matching
 
### 2026-06-08 exporting percentiles + counts of residential, institutional, and vacant counts w/ in Alpine-Joy Boundary into csv
"Q:\3_Projects\ROCKETRUST\Y2 Activity 2 - Alpine-Joy Place-Based Investment Area Analysis\IPDS Summaries\alpine_joy_assessors_sales_20260608.csv"
